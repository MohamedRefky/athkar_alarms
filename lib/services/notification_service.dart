import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/settings_model.dart';
import '../models/dua_model.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final StreamController<String?> selectNotificationStream =
      StreamController<String?>.broadcast();

  static const String _channelId = 'azkar_dua_channel';
  static const String _channelName = 'إشعارات أدعية للأمي';
  static const String _channelDesc = 'إشعارات دورية تذكيرية بالدعاء للأم المتوفاة';

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          selectNotificationStream.add(response.payload);
        }
      },
    );

    await _createNotificationChannel();
  }

  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
      playSound: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  Future<bool> requestPermissions() async {
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    bool granted = false;
    if (androidImplementation != null) {
      final notificationGranted =
          await androidImplementation.requestNotificationsPermission() ?? false;
      granted = notificationGranted;
    }

    final iosImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosImplementation != null) {
      final notificationGranted =
          await iosImplementation.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
              false;
      granted = notificationGranted;
    }

    return granted;
  }

  Future<void> scheduleNotifications({
    required SettingsModel settings,
    required List<DuaModel> duas,
  }) async {
    await cancelAllNotifications();

    if (duas.isEmpty) return;

    final String motherName = settings.motherName;
    final int intervalMinutes = settings.effectiveIntervalMinutes;

    if (settings.frequency == NotificationFrequency.onceDaily) {
      await _scheduleDailyNotification(
        settings: settings,
        duas: duas,
        motherName: motherName,
      );
    } else {
      await _schedulePeriodicNotifications(
        intervalMinutes: intervalMinutes,
        duas: duas,
        motherName: motherName,
        playSound: settings.isAudioEnabled,
      );
    }
  }

  Future<void> _schedulePeriodicNotifications({
    required int intervalMinutes,
    required List<DuaModel> duas,
    required String motherName,
    required bool playSound,
  }) async {
    final RepeatInterval repeatInterval;
    if (intervalMinutes <= 60) {
      repeatInterval = RepeatInterval.hourly;
    } else if (intervalMinutes <= 180) {
      // Periodic fallback using hour intervals
      repeatInterval = RepeatInterval.hourly;
    } else if (intervalMinutes <= 360) {
      repeatInterval = RepeatInterval.hourly;
    } else {
      repeatInterval = RepeatInterval.daily;
    }

    final dua = (duas..shuffle()).first;
    final bodyText = dua.getFormattedText(motherName);

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      playSound: playSound,
      styleInformation: BigTextStyleInformation(bodyText),
    );

    const iosDetails = DarwinNotificationDetails(
      presentSound: true,
      presentAlert: true,
      presentBadge: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.periodicallyShow(
      0,
      'اللهم ارحم أمي 🤍',
      bodyText,
      repeatInterval,
      details,
      payload: 'dua_${dua.id}',
      androidScheduleMode: AndroidScheduleMode.inexact,
    );
  }

  Future<void> _scheduleDailyNotification({
    required SettingsModel settings,
    required List<DuaModel> duas,
    required String motherName,
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      settings.dailyHour,
      settings.dailyMinute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
    final dua = (duas..shuffle()).first;
    final bodyText = dua.getFormattedText(motherName);

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      playSound: settings.isAudioEnabled,
      styleInformation: BigTextStyleInformation(bodyText),
    );

    const iosDetails = DarwinNotificationDetails(
      presentSound: true,
      presentAlert: true,
      presentBadge: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      1,
      'اللهم ارحم أمي 🤍',
      bodyText,
      tzScheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'dua_${dua.id}',
    );
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
    bool playSound = true,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      playSound: playSound,
      styleInformation: BigTextStyleInformation(body),
    );

    const iosDetails = DarwinNotificationDetails(
      presentSound: true,
      presentAlert: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      999,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
