import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import '../domain/audio_config.dart';
import '../ffi/dsp_bridge.dart';

/// 一次音频分析的结果(音高 + 和弦),在后台 isolate 计算后回传主 isolate。
class DspAnalysis {
  final double pitch;
  final ChordResultData chord;

  const DspAnalysis({required this.pitch, required this.chord});
}

/// 后台 isolate 中的 DSP 计算器。
///
/// 音频帧在主 isolate 收集后通过 [feed] 发到这里,所有 FFI 调用都在后台线程完成,
/// 结果通过 [results] 广播流回传。UI 线程不做任何重计算。
///
/// 内部维护一个长度为 [AudioConfig.chordWindowSize] 的环形缓冲:
/// 每积累 [AudioConfig.hopSize] 个新样本就分析一次,
/// 音高检测取最近 [AudioConfig.pitchWindowSize] 个样本(响应快),
/// 和弦检测用完整窗口(频率分辨率高,避免低频 chroma 泄漏)。
class DspWorker {
  Isolate? _isolate;
  SendPort? _commands;
  final _results = StreamController<DspAnalysis>.broadcast();
  final Completer<void> _ready = Completer<void>();
  bool _disposed = false;

  /// 分析结果广播流
  Stream<DspAnalysis> get results => _results.stream;

  /// 是否已在运行
  bool get isRunning => _isolate != null;

  /// 启动后台 isolate。重复调用是安全的;启动失败时静默降级
  /// (结果流不产生数据,UI 停留在"等待音频输入")。
  Future<void> start() async {
    if (_isolate != null || _disposed) return;
    try {
      final receivePort = ReceivePort();
      _isolate = await Isolate.spawn(
        _dspIsolateEntry,
        receivePort.sendPort,
        debugName: 'music_helper_dsp',
      );
      receivePort.listen((message) {
        if (message is SendPort) {
          _commands = message;
          if (!_ready.isCompleted) _ready.complete();
        } else if (message is DspAnalysis) {
          if (!_results.isClosed) _results.add(message);
        }
      });
      await _ready.future;
    } catch (_) {
      _isolate = null;
      if (!_ready.isCompleted) _ready.complete();
    }
  }

  /// 送入一帧原始音频(在主 isolate 调用,内部会拷贝到后台 isolate)
  void feed(Float32List samples) {
    if (samples.isEmpty) return;
    _commands?.send(samples);
  }

  /// 停止后台 isolate 并关闭结果流。可重复调用。
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _commands = null;
    await _results.close();
  }
}

/// 后台 isolate 入口:打开原生库,维护环形缓冲,执行分析。
void _dspIsolateEntry(SendPort mainPort) {
  final port = ReceivePort();
  mainPort.send(port.sendPort);

  final bridge = DspBridge();
  bridge.initialize(AudioConfig.sampleRate);

  final ring = Float32List(AudioConfig.chordWindowSize);
  int writePos = 0;
  int pending = 0;

  port.listen((message) {
    if (message is! Float32List) return;
    final data = message;

    for (int i = 0; i < data.length; i++) {
      ring[writePos] = data[i];
      writePos = (writePos + 1) % AudioConfig.chordWindowSize;
    }
    pending += data.length;

    // 原生库不可用时不分析,但要清空积压避免无限增长
    if (!bridge.isAvailable) {
      pending = 0;
      return;
    }

    while (pending >= AudioConfig.hopSize) {
      pending -= AudioConfig.hopSize;

      // 提取最近的 chordWindowSize 个样本(按时间顺序)
      final window = Float32List(AudioConfig.chordWindowSize);
      for (int i = 0; i < AudioConfig.chordWindowSize; i++) {
        window[i] = ring[(writePos + i) % AudioConfig.chordWindowSize];
      }

      // 音高检测只用最近的 pitchWindowSize 个样本(视图,无拷贝)
      final pitchWindow = Float32List.sublistView(
        window,
        AudioConfig.chordWindowSize - AudioConfig.pitchWindowSize,
      );

      final pitch = bridge.detectPitch(pitchWindow, AudioConfig.sampleRate);
      final chord = bridge.detectChord(window, AudioConfig.sampleRate);
      mainPort.send(DspAnalysis(pitch: pitch, chord: chord));
    }
  });
}
