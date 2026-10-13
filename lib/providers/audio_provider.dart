import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/audio_service.dart';
import '../ffi/dsp_bridge.dart';
import '../domain/audio_config.dart';
import '../domain/note.dart';

// 音频服务 Provider
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
});

// DSP 桥接 Provider
final dspBridgeProvider = Provider<DspBridge>((ref) {
  final bridge = DspBridge();
  bridge.initialize(AudioConfig.sampleRate);
  return bridge;
});

// 调音器状态
class TunerState {
  final double frequency;
  final MusicalNote? note;
  final double centsDeviation;
  final double intensity;
  final bool isActive;

  const TunerState({
    this.frequency = 0,
    this.note,
    this.centsDeviation = 0,
    this.intensity = 0,
    this.isActive = false,
  });

  TunerState copyWith({
    double? frequency,
    MusicalNote? note,
    double? centsDeviation,
    double? intensity,
    bool? isActive,
  }) {
    return TunerState(
      frequency: frequency ?? this.frequency,
      note: note ?? this.note,
      centsDeviation: centsDeviation ?? this.centsDeviation,
      intensity: intensity ?? this.intensity,
      isActive: isActive ?? this.isActive,
    );
  }
}

// 调音器 Notifier
class TunerNotifier extends StateNotifier<TunerState> {
  final AudioService _audioService;
  final DspBridge _dspBridge;

  TunerNotifier(this._audioService, this._dspBridge)
      : super(const TunerState()) {
    _startListening();
  }

  void _startListening() {
    _audioService.startRecording((buffer) {
      final freq = _dspBridge.detectPitch(
        buffer,
        buffer.length,
        AudioConfig.sampleRate,
      );

      if (freq > 0) {
        final note = MusicalNote.fromFrequency(freq);
        final deviation = note.centsDeviation(freq);

        state = state.copyWith(
          frequency: freq,
          note: note,
          centsDeviation: deviation,
          intensity: 1.0,
          isActive: true,
        );
      } else {
        state = state.copyWith(
          frequency: 0,
          note: null,
          centsDeviation: 0,
          intensity: 0,
          isActive: false,
        );
      }
    });
  }

  @override
  void dispose() {
    _audioService.stopRecording();
    super.dispose();
  }
}

final tunerProvider =
    StateNotifierProvider<TunerNotifier, TunerState>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  final dspBridge = ref.watch(dspBridgeProvider);
  return TunerNotifier(audioService, dspBridge);
});

// 和弦检测状态
class ChordState {
  final ChordResultData? result;
  final bool isActive;

  const ChordState({
    this.result,
    this.isActive = false,
  });

  ChordState copyWith({
    ChordResultData? result,
    bool? isActive,
  }) {
    return ChordState(
      result: result ?? this.result,
      isActive: isActive ?? this.isActive,
    );
  }
}

// 和弦检测 Notifier
class ChordNotifier extends StateNotifier<ChordState> {
  final AudioService _audioService;
  final DspBridge _dspBridge;

  // 平滑窗口
  final List<ChordResultData> _window = [];
  static const int _windowSize = 5;

  ChordNotifier(this._audioService, this._dspBridge)
      : super(const ChordState()) {
    _startListening();
  }

  void _startListening() {
    _audioService.startRecording((buffer) {
      final result = _dspBridge.detectChord(
        buffer,
        buffer.length,
        AudioConfig.sampleRate,
      );

      // 多帧平滑
      _window.add(result);
      if (_window.length > _windowSize) {
        _window.removeAt(0);
      }

      if (_window.length >= 3) {
        // 投票：选择出现最多的根音+类型
        final smoothed = _smoothResults(_window);
        state = state.copyWith(
          result: smoothed,
          isActive: true,
        );
      } else {
        state = state.copyWith(
          result: result,
          isActive: true,
        );
      }
    });
  }

  ChordResultData _smoothResults(List<ChordResultData> results) {
    // 简单的多数投票：选置信度最高的结果
    ChordResultData best = results.first;
    for (final r in results) {
      if (r.confidence > best.confidence) {
        best = r;
      }
    }
    return best;
  }

  @override
  void dispose() {
    _audioService.stopRecording();
    super.dispose();
  }
}

final chordProvider =
    StateNotifierProvider<ChordNotifier, ChordState>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  final dspBridge = ref.watch(dspBridgeProvider);
  return ChordNotifier(audioService, dspBridge);
});
