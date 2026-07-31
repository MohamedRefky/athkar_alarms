import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/settings_model.dart';
import '../models/dua_model.dart';
import '../models/audio_azkar_model.dart';
import '../services/preferences_service.dart';
import '../services/notification_service.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final PreferencesService _prefsService;
  final NotificationService _notificationService;

  SettingsCubit(this._prefsService, this._notificationService)
      : super(SettingsState(settings: _prefsService.getSettings()));

  void updateMotherName(String name) async {
    final updated = state.settings.copyWith(motherName: name);
    await _saveAndReschedule(updated);
  }

  void updateCustomSplashImagePath(String? path) async {
    final updated = path == null
        ? state.settings.copyWith(clearSplashImagePath: true)
        : state.settings.copyWith(customSplashImagePath: path);
    await _saveAndReschedule(updated);
  }

  // --- Text Notification Settings ---
  void toggleTextNotifications(bool enabled) async {
    final updated = state.settings.copyWith(isTextNotificationsEnabled: enabled);
    await _saveAndReschedule(updated);
  }

  void updateTextFrequency(NotificationFrequency frequency) async {
    final updated = state.settings.copyWith(textFrequency: frequency);
    await _saveAndReschedule(updated);
  }

  void updateTextCustomInterval(int minutes) async {
    final updated = state.settings.copyWith(
      textCustomIntervalMinutes: minutes,
      textFrequency: NotificationFrequency.custom,
    );
    await _saveAndReschedule(updated);
  }

  void updateTextDailyTime(int hour, int minute) async {
    final updated = state.settings.copyWith(
      textDailyHour: hour,
      textDailyMinute: minute,
    );
    await _saveAndReschedule(updated);
  }

  // --- Audio Notification Settings ---
  void toggleAudioNotifications(bool enabled) async {
    final updated = state.settings.copyWith(isAudioNotificationsEnabled: enabled);
    await _saveAndReschedule(updated);
  }

  void updateAudioFrequency(NotificationFrequency frequency) async {
    final updated = state.settings.copyWith(audioFrequency: frequency);
    await _saveAndReschedule(updated);
  }

  void updateAudioCustomInterval(int minutes) async {
    final updated = state.settings.copyWith(
      audioCustomIntervalMinutes: minutes,
      audioFrequency: NotificationFrequency.custom,
    );
    await _saveAndReschedule(updated);
  }

  void updateAudioDailyTime(int hour, int minute) async {
    final updated = state.settings.copyWith(
      audioDailyHour: hour,
      audioDailyMinute: minute,
    );
    await _saveAndReschedule(updated);
  }

  void updateSelectedAudioIndex(int index) async {
    final updated = state.settings.copyWith(selectedAudioIndex: index);
    await _saveAndReschedule(updated);
  }

  void updateAudioGenderTarget(AudioGenderTarget target) async {
    final updated = state.settings.copyWith(audioGenderTarget: target);
    await _saveAndReschedule(updated);
  }

  void setCustomAudioForDua(int duaId, String filePath) async {
    final updatedMap = Map<int, String>.from(state.settings.customAudioMap);
    updatedMap[duaId] = filePath;
    final updated = state.settings.copyWith(customAudioMap: updatedMap);
    await _saveAndReschedule(updated);
  }

  void removeCustomAudioForDua(int duaId) async {
    final updatedMap = Map<int, String>.from(state.settings.customAudioMap);
    updatedMap.remove(duaId);
    final updated = state.settings.copyWith(customAudioMap: updatedMap);
    await _saveAndReschedule(updated);
  }

  Future<void> _saveAndReschedule(SettingsModel newSettings) async {
    emit(state.copyWith(isSaving: true));
    await _prefsService.saveSettings(newSettings);
    emit(state.copyWith(settings: newSettings, isSaving: false));
  }

  Future<void> rescheduleNotifications({
    required List<DuaModel> duas,
    List<AudioAzkarModel> audioAzkar = const [],
    bool onlyIfEmpty = false,
  }) async {
    await _notificationService.scheduleNotifications(
      settings: state.settings,
      duas: duas,
      audioAzkar: audioAzkar,
      onlyIfEmpty: onlyIfEmpty,
    );
  }
}
