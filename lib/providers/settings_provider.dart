import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/settings_service.dart';
import '../domain/tuning.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

final toleranceProvider = StateNotifierProvider<ToleranceNotifier, double>((ref) {
  return ToleranceNotifier(ref.watch(settingsServiceProvider));
});

class ToleranceNotifier extends StateNotifier<double> {
  final SettingsService _service;

  ToleranceNotifier(this._service) : super(5.0) {
    _load();
  }

  Future<void> _load() async {
    try {
      state = await _service.getTolerance();
    } catch (_) {
      // 持久化不可用(如测试环境)时保留默认值
    }
  }

  Future<void> setTolerance(double value) async {
    state = value;
    try {
      await _service.setTolerance(value);
    } catch (_) {
      // 写入失败不影响内存中的状态
    }
  }
}

final selectedTuningIdProvider =
    StateNotifierProvider<SelectedTuningIdNotifier, String>((ref) {
  return SelectedTuningIdNotifier(ref.watch(settingsServiceProvider));
});

class SelectedTuningIdNotifier extends StateNotifier<String> {
  final SettingsService _service;

  SelectedTuningIdNotifier(this._service) : super('standard_guitar') {
    _load();
  }

  Future<void> _load() async {
    try {
      state = await _service.getSelectedTuningId();
    } catch (_) {
      // 保留默认值
    }
  }

  Future<void> setTuning(String id) async {
    state = id;
    try {
      await _service.setSelectedTuningId(id);
    } catch (_) {
      // 忽略写入失败
    }
  }
}

final customTuningsProvider =
    StateNotifierProvider<CustomTuningsNotifier, List<Tuning>>((ref) {
  return CustomTuningsNotifier(ref.watch(settingsServiceProvider));
});

class CustomTuningsNotifier extends StateNotifier<List<Tuning>> {
  final SettingsService _service;

  CustomTuningsNotifier(this._service) : super([]) {
    _load();
  }

  Future<void> _load() async {
    try {
      state = await _service.getCustomTunings();
    } catch (_) {
      // 保留空列表
    }
  }

  Future<void> addTuning(Tuning tuning) async {
    state = [...state, tuning];
    try {
      await _service.saveCustomTunings(state);
    } catch (_) {
      // 忽略写入失败
    }
  }

  Future<void> removeTuning(String id) async {
    state = state.where((t) => t.id != id).toList();
    try {
      await _service.saveCustomTunings(state);
    } catch (_) {
      // 忽略写入失败
    }
  }
}

final languageProvider =
    StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier(ref.watch(settingsServiceProvider));
});

class LanguageNotifier extends StateNotifier<String> {
  final SettingsService _service;

  LanguageNotifier(this._service) : super('zh') {
    _load();
  }

  Future<void> _load() async {
    try {
      state = await _service.getLanguage();
    } catch (_) {
      // 保留默认值
    }
  }

  Future<void> setLanguage(String lang) async {
    state = lang;
    try {
      await _service.setLanguage(lang);
    } catch (_) {
      // 忽略写入失败
    }
  }
}
