import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

class PreferencesService {
  final SharedPreferences _prefs;

  static const String keyMotherName = 'mother_name';
  static const String keyFrequencyIndex = 'frequency_index';
  static const String keyCustomInterval = 'custom_interval_minutes';
  static const String keyIsAudioEnabled = 'is_audio_enabled';
  static const String keyDailyHour = 'daily_hour';
  static const String keyDailyMinute = 'daily_minute';
  static const String keyCustomAudioMap = 'custom_audio_map';
  static const String keyLastDuaId = 'last_dua_id';

  PreferencesService(this._prefs);

  SettingsModel getSettings() {
    final motherName = _prefs.getString(keyMotherName) ?? 'صباح عجمي أحمد محمد ريان';
    final freqIndex = _prefs.getInt(keyFrequencyIndex) ?? NotificationFrequency.every3Hours.index;
    final customInterval = _prefs.getInt(keyCustomInterval) ?? 120;
    final isAudioEnabled = _prefs.getBool(keyIsAudioEnabled) ?? true;
    final dailyHour = _prefs.getInt(keyDailyHour) ?? 9;
    final dailyMinute = _prefs.getInt(keyDailyMinute) ?? 0;
    
    final customAudioJson = _prefs.getString(keyCustomAudioMap);
    Map<int, String> customAudioMap = {};
    if (customAudioJson != null) {
      try {
        final decoded = jsonDecode(customAudioJson) as Map<String, dynamic>;
        customAudioMap = decoded.map((key, value) => MapEntry(int.parse(key), value as String));
      } catch (_) {}
    }

    final safeFreqIndex = (freqIndex >= 0 && freqIndex < NotificationFrequency.values.length)
        ? freqIndex
        : NotificationFrequency.every3Hours.index;

    return SettingsModel(
      motherName: motherName,
      frequency: NotificationFrequency.values[safeFreqIndex],
      customIntervalMinutes: customInterval,
      isAudioEnabled: isAudioEnabled,
      dailyHour: dailyHour,
      dailyMinute: dailyMinute,
      customAudioMap: customAudioMap,
    );
  }

  Future<void> saveSettings(SettingsModel settings) async {
    await _prefs.setString(keyMotherName, settings.motherName);
    await _prefs.setInt(keyFrequencyIndex, settings.frequency.index);
    await _prefs.setInt(keyCustomInterval, settings.customIntervalMinutes);
    await _prefs.setBool(keyIsAudioEnabled, settings.isAudioEnabled);
    await _prefs.setInt(keyDailyHour, settings.dailyHour);
    await _prefs.setInt(keyDailyMinute, settings.dailyMinute);
    
    final jsonMap = settings.customAudioMap.map((key, value) => MapEntry(key.toString(), value));
    await _prefs.setString(keyCustomAudioMap, jsonEncode(jsonMap));
  }

  int? getLastDuaId() {
    return _prefs.getInt(keyLastDuaId);
  }

  Future<void> saveLastDuaId(int id) async {
    await _prefs.setInt(keyLastDuaId, id);
  }
}
