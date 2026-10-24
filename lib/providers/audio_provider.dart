import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/audio_pipeline.dart';
import '../data/audio_service.dart';
import '../data/dsp_worker.dart';
import '../domain/note.dart';
import '../ffi/dsp_bridge.dart' show ChordResultData;

// 音频服务 Provider(单例)
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
});

// DSP 后台 isolate Provider(单例)
final dspWorkerProvider = Provider<DspWorker>((ref) {
  final worker = DspWorker();
  ref.onDispose(() => worker.dispose());
  return worker;
});

// 音频管线 Provider:惰性创建,被 watch 时才开始录音。
// 调音器/和弦两个页面都依赖它,因此谁先打开谁触发采集,之后两者共享同一条分析流。
final audioPipelineProvider = Provider<AudioPipeline>((ref) {
  final audio = ref.watch(audioServiceProvider);
  final worker = ref.watch(dspWorkerProvider);
  final pipeline = AudioPipeline(audio, worker);
  pipeline.start();
  ref.onDispose(pipeline.dispose);
  return pipeline;
});

// 调音器状态
class TunerState {
  final double frequency;
  final MusicalNote? note;
  final double centsDeviation;
  final bool isActive;

  const TunerState({
    this.frequency = 0,
    this.note,
    this.centsDeviation = 0,
    this.isActive = false,
  });

  TunerState copyWith({
    double? frequency,
    Object? note = _unset,
    double? centsDeviation,
    bool? isActive,
  }) {
    return TunerState(
      frequency: frequency ?? this.frequency,
      note: note == _unset ? this.note : note as MusicalNote?,
      centsDeviation: centsDeviation ?? this.centsDeviation,
      isActive: isActive ?? this.isActive,
    );
  }

  // 哨兵值:让 copyWith 能够把 note 显式置空(信号丢失时清空显示)
  static const Object _unset = Object();
}

// 调音器 Notifier:订阅后台 isolate 的分析结果
class TunerNotifier extends StateNotifier<TunerState> {
  TunerNotifier(this._worker) : super(const TunerState()) {
    _subscription = _worker.results.listen(_onAnalysis);
  }

  final DspWorker _worker;
  StreamSubscription<DspAnalysis>? _subscription;

  void _onAnalysis(DspAnalysis analysis) {
    final pitch = analysis.pitch;
    if (pitch <= 0) {
      // 信号丢失:直接构造新状态,清空音名(避免残留上一个音)
      state = const TunerState();
      return;
    }
    final note = MusicalNote.fromFrequency(pitch);
    state = TunerState(
      frequency: pitch,
      note: note,
      centsDeviation: note.centsDeviation(pitch),
      isActive: true,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final tunerProvider =
    StateNotifierProvider<TunerNotifier, TunerState>((ref) {
  ref.watch(audioPipelineProvider); // 确保录音已启动
  return TunerNotifier(ref.watch(dspWorkerProvider));
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
    Object? result = _unset,
    bool? isActive,
  }) {
    return ChordState(
      result: result == _unset ? this.result : result as ChordResultData?,
      isActive: isActive ?? this.isActive,
    );
  }

  static const Object _unset = Object();
}

// 和弦检测 Notifier:订阅后台 isolate 的分析结果,并对连续帧做多数投票平滑
class ChordNotifier extends StateNotifier<ChordState> {
  ChordNotifier(this._worker) : super(const ChordState()) {
    _subscription = _worker.results.listen(_onAnalysis);
  }

  final DspWorker _worker;
  StreamSubscription<DspAnalysis>? _subscription;

  // 平滑窗口
  final List<ChordResultData> _window = [];
  static const int _windowSize = 5;

  void _onAnalysis(DspAnalysis analysis) {
    _window.add(analysis.chord);
    if (_window.length > _windowSize) {
      _window.removeAt(0);
    }
    state = ChordState(result: _smoothResults(_window), isActive: true);
  }

  /// 多数投票:选出现次数最多的 (根音, 类型) 组合,
  /// 平票时取置信度最高的那一票。比"取单帧最高置信度"更稳定。
  ChordResultData _smoothResults(List<ChordResultData> results) {
    final votes = <String, int>{};
    final bestByKey = <String, ChordResultData>{};
    for (final r in results) {
      final key = '${r.rootIndex}:${r.qualityIndex}';
      votes[key] = (votes[key] ?? 0) + 1;
      final current = bestByKey[key];
      if (current == null || r.confidence > current.confidence) {
        bestByKey[key] = r;
      }
    }

    String? bestKey;
    int bestVotes = -1;
    double bestConfidence = -1;
    bestByKey.forEach((key, result) {
      final count = votes[key]!;
      if (count > bestVotes ||
          (count == bestVotes && result.confidence > bestConfidence)) {
        bestVotes = count;
        bestConfidence = result.confidence;
        bestKey = key;
      }
    });
    return bestByKey[bestKey!]!;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final chordProvider =
    StateNotifierProvider<ChordNotifier, ChordState>((ref) {
  ref.watch(audioPipelineProvider); // 确保录音已启动
  return ChordNotifier(ref.watch(dspWorkerProvider));
});
