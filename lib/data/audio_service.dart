import 'dart:async';
import 'dart:typed_data';
import 'package:record/record.dart';
import '../domain/audio_config.dart';

/// 音频采集服务。
///
/// 单例录音器 + 广播流:调音器与和弦识别两个消费者订阅同一条流,
/// 各自独立处理,互不抢占(旧实现里两个 Notifier 抢同一个录音器,
/// 后启动的那个永远拿不到数据)。
class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  final StreamController<Float32List> _controller =
      StreamController<Float32List>.broadcast();
  StreamSubscription<Uint8List>? _subscription;
  bool _isRecording = false;

  bool get isRecording => _isRecording;

  /// 原始 PCM 浮点音频广播流(单声道,Float32,-1.0 ~ 1.0)
  Stream<Float32List> get audioStream => _controller.stream;

  /// 请求麦克风权限。平台通道不可用(如单元测试环境)时返回 false 而不抛异常。
  Future<bool> hasPermission() async {
    try {
      return await _recorder.hasPermission();
    } catch (_) {
      return false;
    }
  }

  /// 开始采集。权限被拒、设备不支持或平台通道缺失时返回 false,
  /// 流保持不活跃,调用方无需处理异常。
  Future<bool> startRecording() async {
    if (_isRecording) return true;
    if (!await hasPermission()) return false;
    try {
      final stream = await _recorder.startStream(
        const RecordConfig(
          sampleRate: AudioConfig.sampleRate,
          numChannels: 1,
          encoder: AudioEncoder.pcm16bits,
        ),
      );
      _subscription = stream.listen(
        (data) {
          if (!_controller.isClosed) _controller.add(_pcm16ToFloat32(data));
        },
        onError: (_) {
          // 录音流错误不应中断广播流本身
        },
        cancelOnError: false,
      );
      _isRecording = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> stopRecording() async {
    if (!_isRecording) return;
    _isRecording = false;
    await _subscription?.cancel();
    _subscription = null;
    try {
      await _recorder.stop();
    } catch (_) {
      // 已经停止或平台通道缺失
    }
  }

  Future<void> dispose() async {
    await stopRecording();
    try {
      await _recorder.dispose();
    } catch (_) {
      // 忽略
    }
    await _controller.close();
  }

  /// PCM16(小端)转 Float32。Android/iOS 均为小端 ARM,直接按小端解析。
  Float32List _pcm16ToFloat32(Uint8List pcm16) {
    final sampleCount = pcm16.length ~/ 2;
    final float32 = Float32List(sampleCount);
    final byteData = ByteData.sublistView(pcm16);

    for (int i = 0; i < sampleCount; i++) {
      final sample = byteData.getInt16(i * 2, Endian.little);
      float32[i] = sample / 32768.0;
    }

    return float32;
  }
}
