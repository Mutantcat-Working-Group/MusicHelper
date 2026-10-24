import 'dart:async';
import 'dart:typed_data';
import 'audio_service.dart';
import 'dsp_worker.dart';

/// 音频管线:把录音流接到 DSP 后台 isolate。
///
/// 惰性启动——只有第一个需要音频的页面(调音器/和弦)被打开时才开始录音,
/// 避免应用一启动就索取麦克风权限。
class AudioPipeline {
  final AudioService _audio;
  final DspWorker _worker;
  StreamSubscription<Float32List>? _subscription;
  bool _started = false;
  bool _disposed = false;

  AudioPipeline(this._audio, this._worker);

  /// 是否正在采集(权限被拒或平台不支持时为 false)
  bool get isCapturing => _audio.isRecording;

  Future<void> start() async {
    if (_started || _disposed) return;
    _started = true;
    await _worker.start();
    _subscription = _audio.audioStream.listen(_worker.feed);
    await _audio.startRecording();
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _subscription?.cancel();
    _subscription = null;
    await _audio.stopRecording();
  }
}
