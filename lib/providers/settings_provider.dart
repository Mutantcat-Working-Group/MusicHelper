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
    state = await _service.getTolerance();
  }

  Future<void> setTolerance(double value) async {
    state = value;
    await _service.setTolerance(value);
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
    state = await _service.getSelectedTuningId();
  }

  Future<void> setTuning(String id) async {
    state = id;
    await _service.setSelectedTuningId(id);
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
    state = await _service.getCustomTunings();
  }

  Future<void> addTuning(Tuning tuning) async {
    state = [...state, tuning];
    await _service.saveCustomTunings(state);
  }

  Future<void> removeTuning(String id) async {
    state = state.where((t) => t.id != id).toList();
    await _service.saveCustomTunings(state);
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
    state = await _service.getLanguage();
  }

  Future<void> setLanguage(String lang) async {
    state = lang;
    await _service.setLanguage(lang);
  }
}
