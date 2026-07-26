import 'package:equatable/equatable.dart';

enum NotificationFrequency {
  every1Hour,
  every3Hours,
  every6Hours,
  onceDaily,
  custom,
}

extension NotificationFrequencyX on NotificationFrequency {
  String get label {
    switch (this) {
      case NotificationFrequency.every1Hour:
        return 'كل ساعة';
      case NotificationFrequency.every3Hours:
        return 'كل 3 ساعات';
      case NotificationFrequency.every6Hours:
        return 'كل 6 ساعات';
      case NotificationFrequency.onceDaily:
        return 'مرة واحدة يومياً';
      case NotificationFrequency.custom:
        return 'وقت مخصص';
    }
  }

  int get intervalMinutes {
    switch (this) {
      case NotificationFrequency.every1Hour:
        return 60;
      case NotificationFrequency.every3Hours:
        return 180;
      case NotificationFrequency.every6Hours:
        return 360;
      case NotificationFrequency.onceDaily:
        return 1440;
      case NotificationFrequency.custom:
        return 30; // default for custom if not set
    }
  }
}

class SettingsModel extends Equatable {
  final String motherName;
  final NotificationFrequency frequency;
  final int customIntervalMinutes;
  final bool isAudioEnabled;
  final int dailyHour;
  final int dailyMinute;
  final Map<int, String> customAudioMap;

  const SettingsModel({
    this.motherName = '',
    this.frequency = NotificationFrequency.every3Hours,
    this.customIntervalMinutes = 120,
    this.isAudioEnabled = true,
    this.dailyHour = 9,
    this.dailyMinute = 0,
    this.customAudioMap = const {},
  });

  SettingsModel copyWith({
    String? motherName,
    NotificationFrequency? frequency,
    int? customIntervalMinutes,
    bool? isAudioEnabled,
    int? dailyHour,
    int? dailyMinute,
    Map<int, String>? customAudioMap,
  }) {
    return SettingsModel(
      motherName: motherName ?? this.motherName,
      frequency: frequency ?? this.frequency,
      customIntervalMinutes: customIntervalMinutes ?? this.customIntervalMinutes,
      isAudioEnabled: isAudioEnabled ?? this.isAudioEnabled,
      dailyHour: dailyHour ?? this.dailyHour,
      dailyMinute: dailyMinute ?? this.dailyMinute,
      customAudioMap: customAudioMap ?? this.customAudioMap,
    );
  }

  int get effectiveIntervalMinutes {
    if (frequency == NotificationFrequency.custom) {
      return customIntervalMinutes > 0 ? customIntervalMinutes : 60;
    }
    return frequency.intervalMinutes;
  }

  @override
  List<Object?> get props => [
        motherName,
        frequency,
        customIntervalMinutes,
        isAudioEnabled,
        dailyHour,
        dailyMinute,
        customAudioMap,
      ];
}
