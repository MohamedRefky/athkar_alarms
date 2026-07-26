import 'package:equatable/equatable.dart';

enum NotificationFrequency {
  every15Minutes,
  every30Minutes,
  every1Hour,
  every2Hours,
  every3Hours,
  every6Hours,
  every12Hours,
  onceDaily,
  custom,
}

extension NotificationFrequencyX on NotificationFrequency {
  String get label {
    switch (this) {
      case NotificationFrequency.every15Minutes:
        return 'كل 15 دقيقة';
      case NotificationFrequency.every30Minutes:
        return 'كل 30 دقيقة';
      case NotificationFrequency.every1Hour:
        return 'كل ساعة';
      case NotificationFrequency.every2Hours:
        return 'كل ساعتين';
      case NotificationFrequency.every3Hours:
        return 'كل 3 ساعات';
      case NotificationFrequency.every6Hours:
        return 'كل 6 ساعات';
      case NotificationFrequency.every12Hours:
        return 'كل 12 ساعة';
      case NotificationFrequency.onceDaily:
        return 'مرة واحدة يومياً';
      case NotificationFrequency.custom:
        return 'وقت مخصص';
    }
  }

  int get intervalMinutes {
    switch (this) {
      case NotificationFrequency.every15Minutes:
        return 15;
      case NotificationFrequency.every30Minutes:
        return 30;
      case NotificationFrequency.every1Hour:
        return 60;
      case NotificationFrequency.every2Hours:
        return 120;
      case NotificationFrequency.every3Hours:
        return 180;
      case NotificationFrequency.every6Hours:
        return 360;
      case NotificationFrequency.every12Hours:
        return 720;
      case NotificationFrequency.onceDaily:
        return 1440;
      case NotificationFrequency.custom:
        return 60;
    }
  }
}

class SettingsModel extends Equatable {
  final String motherName;

  // Text Notifications (Written Duas)
  final bool isTextNotificationsEnabled;
  final NotificationFrequency textFrequency;
  final int textCustomIntervalMinutes;
  final int textDailyHour;
  final int textDailyMinute;

  // Audio Notifications (Recorded Audio Clips)
  final bool isAudioNotificationsEnabled;
  final NotificationFrequency audioFrequency;
  final int audioCustomIntervalMinutes;
  final int audioDailyHour;
  final int audioDailyMinute;
  final int selectedAudioIndex; // 0 = Sequential Loop (1..16), >0 = Specific sound

  // Legacy fallback fields for backward compatibility
  final Map<int, String> customAudioMap;

  const SettingsModel({
    this.motherName = 'صباح عجمي أحمد محمد ريان',
    this.isTextNotificationsEnabled = true,
    this.textFrequency = NotificationFrequency.every3Hours,
    this.textCustomIntervalMinutes = 180,
    this.textDailyHour = 9,
    this.textDailyMinute = 0,
    this.isAudioNotificationsEnabled = true,
    this.audioFrequency = NotificationFrequency.every1Hour,
    this.audioCustomIntervalMinutes = 60,
    this.audioDailyHour = 17,
    this.audioDailyMinute = 0,
    this.selectedAudioIndex = 0,
    this.customAudioMap = const {},
  });

  // Getters for legacy fields if used
  bool get isAudioEnabled => isAudioNotificationsEnabled;
  NotificationFrequency get frequency => textFrequency;
  int get customIntervalMinutes => textCustomIntervalMinutes;
  int get dailyHour => textDailyHour;
  int get dailyMinute => textDailyMinute;

  SettingsModel copyWith({
    String? motherName,
    bool? isTextNotificationsEnabled,
    NotificationFrequency? textFrequency,
    int? textCustomIntervalMinutes,
    int? textDailyHour,
    int? textDailyMinute,
    bool? isAudioNotificationsEnabled,
    NotificationFrequency? audioFrequency,
    int? audioCustomIntervalMinutes,
    int? audioDailyHour,
    int? audioDailyMinute,
    int? selectedAudioIndex,
    Map<int, String>? customAudioMap,
  }) {
    return SettingsModel(
      motherName: motherName ?? this.motherName,
      isTextNotificationsEnabled:
          isTextNotificationsEnabled ?? this.isTextNotificationsEnabled,
      textFrequency: textFrequency ?? this.textFrequency,
      textCustomIntervalMinutes:
          textCustomIntervalMinutes ?? this.textCustomIntervalMinutes,
      textDailyHour: textDailyHour ?? this.textDailyHour,
      textDailyMinute: textDailyMinute ?? this.textDailyMinute,
      isAudioNotificationsEnabled:
          isAudioNotificationsEnabled ?? this.isAudioNotificationsEnabled,
      audioFrequency: audioFrequency ?? this.audioFrequency,
      audioCustomIntervalMinutes:
          audioCustomIntervalMinutes ?? this.audioCustomIntervalMinutes,
      audioDailyHour: audioDailyHour ?? this.audioDailyHour,
      audioDailyMinute: audioDailyMinute ?? this.audioDailyMinute,
      selectedAudioIndex: selectedAudioIndex ?? this.selectedAudioIndex,
      customAudioMap: customAudioMap ?? this.customAudioMap,
    );
  }

  int getEffectiveTextIntervalMinutes() {
    if (textFrequency == NotificationFrequency.custom) {
      return textCustomIntervalMinutes > 0 ? textCustomIntervalMinutes : 60;
    }
    return textFrequency.intervalMinutes;
  }

  int getEffectiveAudioIntervalMinutes() {
    if (audioFrequency == NotificationFrequency.custom) {
      return audioCustomIntervalMinutes > 0 ? audioCustomIntervalMinutes : 60;
    }
    return audioFrequency.intervalMinutes;
  }

  @override
  List<Object?> get props => [
        motherName,
        isTextNotificationsEnabled,
        textFrequency,
        textCustomIntervalMinutes,
        textDailyHour,
        textDailyMinute,
        isAudioNotificationsEnabled,
        audioFrequency,
        audioCustomIntervalMinutes,
        audioDailyHour,
        audioDailyMinute,
        selectedAudioIndex,
        customAudioMap,
      ];
}
