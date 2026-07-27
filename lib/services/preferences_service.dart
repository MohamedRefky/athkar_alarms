import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

class PreferencesService {
  final SharedPreferences _prefs;

  static const String keyMotherName = 'mother_name';

  // Text Notifications Keys
  static const String keyIsTextEnabled = 'is_text_notifications_enabled';
  static const String keyTextFrequencyIndex = 'text_frequency_index';
  static const String keyTextCustomInterval = 'text_custom_interval_minutes';
  static const String keyTextDailyHour = 'text_daily_hour';
  static const String keyTextDailyMinute = 'text_daily_minute';

  // Audio Notifications Keys
  static const String keyIsAudioEnabled = 'is_audio_notifications_enabled';
  static const String keyAudioFrequencyIndex = 'audio_frequency_index';
  static const String keyAudioCustomInterval = 'audio_custom_interval_minutes';
  static const String keyAudioDailyHour = 'audio_daily_hour';
  static const String keyAudioDailyMinute = 'audio_daily_minute';
  static const String keySelectedAudioIndex = 'selected_audio_index';

  static const String keyCustomSplashImagePath = 'custom_splash_image_path';
  static const String keyCustomAudioMap = 'custom_audio_map';
  static const String keyLastDuaId = 'last_dua_id';

  PreferencesService(this._prefs);

  SettingsModel getSettings() {
    final motherName =
        _prefs.getString(keyMotherName) ?? 'صباح عجمي أحمد محمد ريان';

    // Text settings
    final isTextEnabled = _prefs.getBool(keyIsTextEnabled) ?? true;
    final textFreqIdx =
        _prefs.getInt(keyTextFrequencyIndex) ?? NotificationFrequency.custom.index;
    final textCustomInterval = _prefs.getInt(keyTextCustomInterval) ?? 180;
    final textDailyHour = _prefs.getInt(keyTextDailyHour) ?? 9;
    final textDailyMinute = _prefs.getInt(keyTextDailyMinute) ?? 0;

    // Audio settings
    final isAudioEnabled = _prefs.getBool(keyIsAudioEnabled) ?? true;
    final audioFreqIdx =
        _prefs.getInt(keyAudioFrequencyIndex) ?? NotificationFrequency.custom.index;
    final audioCustomInterval = _prefs.getInt(keyAudioCustomInterval) ?? 60;
    final audioDailyHour = _prefs.getInt(keyAudioDailyHour) ?? 17;
    final audioDailyMinute = _prefs.getInt(keyAudioDailyMinute) ?? 0;
    final selectedAudioIndex = _prefs.getInt(keySelectedAudioIndex) ?? 0;

    // Splash Image
    final customSplashImagePath = _prefs.getString(keyCustomSplashImagePath);

    final customAudioJson = _prefs.getString(keyCustomAudioMap);
    Map<int, String> customAudioMap = {};
    if (customAudioJson != null) {
      try {
        final decoded = jsonDecode(customAudioJson) as Map<String, dynamic>;
        customAudioMap =
            decoded.map((key, value) => MapEntry(int.parse(key), value as String));
      } catch (_) {}
    }

    final safeTextFreqIdx =
        (textFreqIdx >= 0 && textFreqIdx < NotificationFrequency.values.length)
            ? textFreqIdx
            : NotificationFrequency.custom.index;

    final safeAudioFreqIdx =
        (audioFreqIdx >= 0 && audioFreqIdx < NotificationFrequency.values.length)
            ? audioFreqIdx
            : NotificationFrequency.custom.index;

    return SettingsModel(
      motherName: motherName,
      isTextNotificationsEnabled: isTextEnabled,
      textFrequency: NotificationFrequency.values[safeTextFreqIdx],
      textCustomIntervalMinutes: textCustomInterval,
      textDailyHour: textDailyHour,
      textDailyMinute: textDailyMinute,
      isAudioNotificationsEnabled: isAudioEnabled,
      audioFrequency: NotificationFrequency.values[safeAudioFreqIdx],
      audioCustomIntervalMinutes: audioCustomInterval,
      audioDailyHour: audioDailyHour,
      audioDailyMinute: audioDailyMinute,
      selectedAudioIndex: selectedAudioIndex,
      customSplashImagePath: customSplashImagePath,
      customAudioMap: customAudioMap,
    );
  }

  Future<void> saveSettings(SettingsModel settings) async {
    await _prefs.setString(keyMotherName, settings.motherName);

    // Text settings
    await _prefs.setBool(
        keyIsTextEnabled, settings.isTextNotificationsEnabled);
    await _prefs.setInt(keyTextFrequencyIndex, settings.textFrequency.index);
    await _prefs.setInt(
        keyTextCustomInterval, settings.textCustomIntervalMinutes);
    await _prefs.setInt(keyTextDailyHour, settings.textDailyHour);
    await _prefs.setInt(keyTextDailyMinute, settings.textDailyMinute);

    // Audio settings
    await _prefs.setBool(
        keyIsAudioEnabled, settings.isAudioNotificationsEnabled);
    await _prefs.setInt(keyAudioFrequencyIndex, settings.audioFrequency.index);
    await _prefs.setInt(
        keyAudioCustomInterval, settings.audioCustomIntervalMinutes);
    await _prefs.setInt(keyAudioDailyHour, settings.audioDailyHour);
    await _prefs.setInt(keyAudioDailyMinute, settings.audioDailyMinute);
    await _prefs.setInt(keySelectedAudioIndex, settings.selectedAudioIndex);

    // Splash Image
    if (settings.customSplashImagePath != null) {
      await _prefs.setString(keyCustomSplashImagePath, settings.customSplashImagePath!);
    } else {
      await _prefs.remove(keyCustomSplashImagePath);
    }

    final jsonMap =
        settings.customAudioMap.map((key, value) => MapEntry(key.toString(), value));
    await _prefs.setString(keyCustomAudioMap, jsonEncode(jsonMap));
  }

  int? getLastDuaId() {
    return _prefs.getInt(keyLastDuaId);
  }

  Future<void> saveLastDuaId(int id) async {
    await _prefs.setInt(keyLastDuaId, id);
  }
}
