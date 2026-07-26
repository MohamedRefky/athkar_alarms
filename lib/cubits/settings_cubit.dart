import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/settings_model.dart';
import '../models/dua_model.dart';
import '../services/preferences_service.dart';
import '../services/notification_service.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final PreferencesService _prefsService;
  final NotificationService _notificationService;

  SettingsCubit(this._prefsService, this._notificationService)
      : super(SettingsState(settings: _prefsService.getSettings()));

  void updateMotherName(String name) async {
    final updated = state.settings.copyWith(motherName: name.trim());
    await _saveAndReschedule(updated);
  }

  void updateFrequency(NotificationFrequency frequency) async {
    final updated = state.settings.copyWith(frequency: frequency);
    await _saveAndReschedule(updated);
  }

  void updateCustomInterval(int minutes) async {
    final updated = state.settings.copyWith(customIntervalMinutes: minutes);
    await _saveAndReschedule(updated);
  }

  void toggleAudio(bool enabled) async {
    final updated = state.settings.copyWith(isAudioEnabled: enabled);
    await _saveAndReschedule(updated);
  }

  void updateDailyTime(int hour, int minute) async {
    final updated = state.settings.copyWith(
      dailyHour: hour,
      dailyMinute: minute,
    );
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

  Future<void> rescheduleNotifications(List<DuaModel> duas) async {
    await _notificationService.scheduleNotifications(
      settings: state.settings,
      duas: duas,
    );
  }
}
