import 'package:shared_preferences/shared_preferences.dart';
import '../domain/tuning.dart';
import 'dart:convert';

/// 设置持久化服务
class SettingsService {
  static const String _toleranceKey = 'tolerance_cents';
  static const String _selectedTuningIdKey = 'selected_tuning_id';
  static const String _customTuningsKey = 'custom_tunings';
  static const String _languageKey = 'language';

  Future<double> getTolerance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_toleranceKey) ?? 5.0;
  }

  Future<void> setTolerance(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_toleranceKey, value);
  }

  Future<String> getSelectedTuningId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedTuningIdKey) ?? 'standard_guitar';
  }

  Future<void> setSelectedTuningId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedTuningIdKey, id);
  }

  Future<List<Tuning>> getCustomTunings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_customTuningsKey);
    if (jsonStr == null) return [];

    final List<dynamic> jsonList = json.decode(jsonStr);
    return jsonList.map((j) => Tuning.fromJson(j)).toList();
  }

  Future<void> saveCustomTunings(List<Tuning> tunings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(tunings.map((t) => t.toJson()).toList());
    await prefs.setString(_customTuningsKey, jsonStr);
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'zh';
  }

  Future<void> setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, lang);
  }
}
