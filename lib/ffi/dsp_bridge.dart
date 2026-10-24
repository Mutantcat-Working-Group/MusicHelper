import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart' as ffi;

/// FFI 绑定到 C++ DSP 库。
///
/// C 侧所有函数都使用「出参」风格:结构体内存由 Dart 侧用 calloc 分配并传入,
/// 不存在跨语言的内存所有权转移,因此不需要(也不能)释放 C 侧返回的指针。
///
/// 原生库缺失或符号找不到时(例如测试环境、未接入原生库的平台),
/// [DspBridge] 会降级为不可用状态,所有检测返回空结果而不是抛异常。
class DspBridge {
  static DynamicLibrary? _lib;
  static bool _loadAttempted = false;

  /// 打开原生库。失败返回 null(只尝试一次,结果缓存)。
  static DynamicLibrary? _openLibrary() {
    if (_loadAttempted) return _lib;
    _loadAttempted = true;
    try {
      if (Platform.isAndroid) {
        _lib = DynamicLibrary.open('libmusic_helper_dsp.so');
      } else if (Platform.isIOS) {
        // iOS 侧原生代码通过 CocoaPods 静态/动态链接进 app 二进制,
        // 符号可以直接从当前进程解析。
        _lib = DynamicLibrary.process();
      } else {
        _lib = DynamicLibrary.open('libmusic_helper_dsp.so');
      }
    } catch (_) {
      _lib = null;
    }
    return _lib;
  }

  /// 原生库是否可用。不可用时所有检测方法返回空结果。
  final bool isAvailable;

  late final void Function(int sampleRate) _dspInit;
  late final double Function(Pointer<Float> samples, int sampleCount, int sampleRate)
      _mpmDetectPitch;
  late final void Function(
          Pointer<Float> samples, int sampleCount, int sampleRate, Pointer<MultiPitchResult> out)
      _detectMultiplePitches;
  late final void Function(
          Pointer<Float> samples, int sampleCount, int sampleRate, Pointer<ChordResult> out)
      _detectChord;

  DspBridge._(DynamicLibrary lib) : isAvailable = true {
    _dspInit = lib.lookupFunction<Void Function(Int32), void Function(int)>('dsp_init');

    _mpmDetectPitch = lib.lookupFunction<
        Float Function(Pointer<Float>, Int32, Int32),
        double Function(Pointer<Float>, int, int)>('mpm_detect_pitch');

    _detectMultiplePitches = lib.lookupFunction<
        Void Function(Pointer<Float>, Int32, Int32, Pointer<MultiPitchResult>),
        void Function(
            Pointer<Float>, int, int, Pointer<MultiPitchResult>)>('detect_multiple_pitches');

    _detectChord = lib.lookupFunction<
        Void Function(Pointer<Float>, Int32, Int32, Pointer<ChordResult>),
        void Function(Pointer<Float>, int, int, Pointer<ChordResult>)>('detect_chord');
  }

  DspBridge._unavailable() : isAvailable = false;

  /// 创建桥接实例。原生库不可用时返回降级实例(不抛异常)。
  factory DspBridge() {
    final lib = _openLibrary();
    if (lib == null) return DspBridge._unavailable();
    try {
      return DspBridge._(lib);
    } catch (_) {
      // 符号缺失等情况
      return DspBridge._unavailable();
    }
  }

  void initialize(int sampleRate) {
    if (isAvailable) _dspInit(sampleRate);
  }

  /// MPM 音高检测,返回频率(Hz);0 表示未检测到可靠音高。
  double detectPitch(Float32List samples, int sampleRate) {
    if (!isAvailable || samples.isEmpty) return 0;
    final ptr = ffi.calloc<Float>(samples.length);
    try {
      ptr.asTypedList(samples.length).setAll(0, samples);
      return _mpmDetectPitch(ptr, samples.length, sampleRate);
    } finally {
      ffi.calloc.free(ptr);
    }
  }

  /// 多音高检测(HPS)。
  MultiPitchResultData detectMultiplePitches(Float32List samples, int sampleRate) {
    if (!isAvailable || samples.isEmpty) return MultiPitchResultData.empty();
    final ptr = ffi.calloc<Float>(samples.length);
    final out = ffi.calloc<MultiPitchResult>();
    try {
      ptr.asTypedList(samples.length).setAll(0, samples);
      _detectMultiplePitches(ptr, samples.length, sampleRate, out);
      return MultiPitchResultData.fromNative(out.ref);
    } finally {
      ffi.calloc.free(out);
      ffi.calloc.free(ptr);
    }
  }

  /// 和弦检测。
  ChordResultData detectChord(Float32List samples, int sampleRate) {
    if (!isAvailable || samples.isEmpty) return ChordResultData.empty();
    final ptr = ffi.calloc<Float>(samples.length);
    final out = ffi.calloc<ChordResult>();
    try {
      ptr.asTypedList(samples.length).setAll(0, samples);
      _detectChord(ptr, samples.length, sampleRate, out);
      return ChordResultData.fromNative(out.ref);
    } finally {
      ffi.calloc.free(out);
      ffi.calloc.free(ptr);
    }
  }
}

// FFI 结构体定义(与 native/dsp/dsp_bridge.h 中的 C 结构体逐字段对应)
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

// 多音高检测结果(Dart 侧副本)
class MultiPitchResultData {
  final List<double> frequencies;
  final List<double> intensities;
  final int count;

  const MultiPitchResultData({
    required this.frequencies,
    required this.intensities,
    required this.count,
  });

  factory MultiPitchResultData.empty() =>
      const MultiPitchResultData(frequencies: [], intensities: [], count: 0);

  factory MultiPitchResultData.fromNative(MultiPitchResult native) {
    // count 由 C 侧写入,钳位到数组容量防止越界读
    final count = native.count.clamp(0, 12);
    return MultiPitchResultData(
      frequencies: List.generate(count, (i) => native.frequencies[i]),
      intensities: List.generate(count, (i) => native.intensities[i]),
      count: count,
    );
  }
}

// 和弦检测结果(Dart 侧副本)
class ChordResultData {
  final int rootIndex;
  final int qualityIndex;
  final int bassIndex;
  final double confidence;
  final List<double> chroma;
  final List<double> detectedNotes;

  const ChordResultData({
    required this.rootIndex,
    required this.qualityIndex,
    required this.bassIndex,
    required this.confidence,
    required this.chroma,
    required this.detectedNotes,
  });

  factory ChordResultData.empty() => ChordResultData(
        rootIndex: 0,
        qualityIndex: 0,
        bassIndex: 0,
        confidence: 0,
        chroma: List.filled(12, 0),
        detectedNotes: List.filled(12, 0),
      );

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
