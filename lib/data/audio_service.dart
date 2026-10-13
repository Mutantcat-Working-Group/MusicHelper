import 'dart:typed_data';
import 'package:record/record.dart';
import '../domain/audio_config.dart';

/// 音频采集服务
class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;

  bool get isRecording => _isRecording;

  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  Future<void> startRecording(void Function(Float32List buffer) onData) async {
    if (_isRecording) return;

    final stream = await _recorder.startStream(
      const RecordConfig(
        sampleRate: AudioConfig.sampleRate,
        channelCount: 1,
        encoder: AudioEncoder.pcm16bits,
      ),
    );

    _isRecording = true;
    stream.listen((data) {
      final floatData = _pcm16ToFloat32(data);
      onData(floatData);
    });
  }

  Future<void> stopRecording() async {
    if (!_isRecording) return;
    await _recorder.stop();
    _isRecording = false;
  }

  Future<void> dispose() async {
    await stopRecording();
    await _recorder.dispose();
  }

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
