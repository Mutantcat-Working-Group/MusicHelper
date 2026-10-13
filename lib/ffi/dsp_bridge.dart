import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

/// FFI 绑定到 C++ DSP 库
class DspBridge {
  static DynamicLibrary? _lib;

  static DynamicLibrary get library {
    if (_lib != null) return _lib!;
    if (Platform.isAndroid) {
      _lib = DynamicLibrary.open('libmusic_helper_dsp.so');
    } else if (Platform.isIOS) {
      _lib = DynamicLibrary.process();
    } else {
      _lib = DynamicLibrary.open('libmusic_helper_dsp.so');
    }
    return _lib!;
  }

  // MPM 音高检测
  late final double Function(Pointer<Float> samples, int sampleCount, int sampleRate)
      _mpmDetectPitch;

  // 多音高检测
  late final Pointer<MultiPitchResult> Function(
          Pointer<Float> samples, int sampleCount, int sampleRate)
      _detectMultiplePitches;

  // 和弦检测
  late final Pointer<ChordResult> Function(
          Pointer<Float> samples, int sampleCount, int sampleRate)
      _detectChord;

  // 初始化
  late final void Function(int sampleRate) _dspInit;

  DspBridge() {
    final lib = library;

    _mpmDetectPitch = lib.lookupFunction<
        Float Function(Pointer<Float>, Int32, Int32),
        double Function(Pointer<Float>, int, int)>('mpm_detect_pitch');

    _detectMultiplePitches = lib.lookupFunction<
        Pointer<MultiPitchResult> Function(Pointer<Float>, Int32, Int32),
        Pointer<MultiPitchResult> Function(
            Pointer<Float>, int, int)>('detect_multiple_pitches');

    _detectChord = lib.lookupFunction<
        Pointer<ChordResult> Function(Pointer<Float>, Int32, Int32),
        Pointer<ChordResult> Function(Pointer<Float>, int, int)>('detect_chord');

    _dspInit = lib.lookupFunction<Void Function(Int32), void Function(int)>(
        'dsp_init');
  }

  void initialize(int sampleRate) => _dspInit(sampleRate);

  double detectPitch(Float32List samples, int sampleCount, int sampleRate) {
    final ptr = _calloc(samples.length);
    try {
      final list = ptr.asTypedList(samples.length);
      list.setAll(0, samples);
      return _mpmDetectPitch(ptr, sampleCount, sampleRate);
    } finally {
      _free(ptr);
    }
  }

  MultiPitchResultData detectMultiplePitches(
      Float32List samples, int sampleCount, int sampleRate) {
    final ptr = _calloc(samples.length);
    try {
      final list = ptr.asTypedList(samples.length);
      list.setAll(0, samples);
      final resultPtr = _detectMultiplePitches(ptr, sampleCount, sampleRate);
      final result = MultiPitchResultData.fromNative(resultPtr.ref);
      _free(resultPtr);
      return result;
    } finally {
      _free(ptr);
    }
  }

  ChordResultData detectChord(
      Float32List samples, int sampleCount, int sampleRate) {
    final ptr = _calloc(samples.length);
    try {
      final list = ptr.asTypedList(samples.length);
      list.setAll(0, samples);
      final resultPtr = _detectChord(ptr, sampleCount, sampleRate);
      final result = ChordResultData.fromNative(resultPtr.ref);
      _free(resultPtr);
      return result;
    } finally {
      _free(ptr);
    }
  }

  static Pointer<T> _calloc<T extends NativeType>(int count) =>
      calloc<T>(count);
  static void _free(Pointer ptr) => calloc.free(ptr);
}

// FFI 结构体定义
final class MultiPitchResult extends Struct {
  @Array(12)
  external Array<Float> frequencies;

  @Array(12)
  external Array<Float> intensities;

  @Int32()
  external int count;
}

final class ChordResult extends Struct {
  @Int32()
  external int rootIndex;

  @Int32()
  external int qualityIndex;

  @Int32()
  external int bassIndex;

  @Float()
  external double confidence;

  @Array(12)
  external Array<Float> chroma;

  @Array(12)
  external Array<Float> detectedNotes;
}

// 多音高检测结果（Dart 侧副本）
class MultiPitchResultData {
  final List<double> frequencies;
  final List<double> intensities;
  final int count;

  MultiPitchResultData({
    required this.frequencies,
    required this.intensities,
    required this.count,
  });

  factory MultiPitchResultData.fromNative(MultiPitchResult native) {
    return MultiPitchResultData(
      frequencies: List.generate(native.count, (i) => native.frequencies[i]),
      intensities: List.generate(native.count, (i) => native.intensities[i]),
      count: native.count,
    );
  }
}

// 和弦检测结果（Dart 侧副本）
class ChordResultData {
  final int rootIndex;
  final int qualityIndex;
  final int bassIndex;
  final double confidence;
  final List<double> chroma;
  final List<double> detectedNotes;

  ChordResultData({
    required this.rootIndex,
    required this.qualityIndex,
    required this.bassIndex,
    required this.confidence,
    required this.chroma,
    required this.detectedNotes,
  });

  factory ChordResultData.fromNative(ChordResult native) {
    return ChordResultData(
      rootIndex: native.rootIndex,
      qualityIndex: native.qualityIndex,
      bassIndex: native.bassIndex,
      confidence: native.confidence,
      chroma: List.generate(12, (i) => native.chroma[i]),
      detectedNotes: List.generate(12, (i) => native.detectedNotes[i]),
    );
  }
}
