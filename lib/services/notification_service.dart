import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/settings_model.dart';
import '../models/dua_model.dart';
import '../models/audio_azkar_model.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final StreamController<String?> selectNotificationStream =
      StreamController<String?>.broadcast();

  // Distinct channels
  static const String _textChannelId = 'azkar_text_channel_v1';
  static const String _textChannelName = 'إشعارات الأدعية المكتوبة';
  static const String _textChannelDesc = 'تذكيرات دورية بالأدعية المكتوبة للأم المتوفاة';

  static const String _audioChannelId = 'azkar_audio_channel_v1';
  static const String _audioChannelName = 'الإشعارات والتسجيلات الصوتية';
  static const String _audioChannelDesc = 'إشعارات صوتية مخصصة للأدعية';

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

    await _createNotificationChannels();
  }

  Future<void> _createNotificationChannels() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation == null) return;

    // 1. Text Dua Channel
    const textChannel = AndroidNotificationChannel(
      _textChannelId,
      _textChannelName,
      description: _textChannelDesc,
      importance: Importance.high,
      playSound: true,
    );
    await androidImplementation.createNotificationChannel(textChannel);

    // 2. Audio Azkar Channel (Default Sound: azkar_sound)
    const audioChannel = AndroidNotificationChannel(
      _audioChannelId,
      _audioChannelName,
      description: _audioChannelDesc,
      importance: Importance.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('azkar_sound'),
    );
    await androidImplementation.createNotificationChannel(audioChannel);
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
    List<AudioAzkarModel> audioAzkar = const [],
  }) async {
    await cancelAllNotifications();

    if (settings.isTextNotificationsEnabled && duas.isNotEmpty) {
      await _scheduleTextNotifications(settings: settings, duas: duas);
    }

    if (settings.isAudioNotificationsEnabled && audioAzkar.isNotEmpty) {
      await _scheduleAudioNotifications(
        settings: settings,
        audioAzkar: audioAzkar,
      );
    }
  }

  // --- Text Notifications Scheduling ---
  Future<void> _scheduleTextNotifications({
    required SettingsModel settings,
    required List<DuaModel> duas,
  }) async {
    final String motherName = settings.motherName;

    if (settings.textFrequency == NotificationFrequency.onceDaily) {
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        settings.textDailyHour,
        settings.textDailyMinute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
      final dua = (duas..shuffle()).first;
      final bodyText = dua.getFormattedText(motherName);

      const androidDetails = AndroidNotificationDetails(
        _textChannelId,
        _textChannelName,
        channelDescription: _textChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        styleInformation: BigTextStyleInformation(''),
      );

      const iosDetails = DarwinNotificationDetails(
        presentSound: true,
        presentAlert: true,
        presentBadge: true,
      );

      await _notificationsPlugin.zonedSchedule(
        100, // ID prefix for text daily
        'اللهم ارحم أمي 🤍',
        bodyText,
        tzScheduledDate,
        const NotificationDetails(android: androidDetails, iOS: iosDetails),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'dua_${dua.id}',
      );
    } else {
      final dua = (duas..shuffle()).first;
      final bodyText = dua.getFormattedText(motherName);

      const androidDetails = AndroidNotificationDetails(
        _textChannelId,
        _textChannelName,
        channelDescription: _textChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        styleInformation: BigTextStyleInformation(''),
      );

      const iosDetails = DarwinNotificationDetails(
        presentSound: true,
        presentAlert: true,
        presentBadge: true,
      );

      await _notificationsPlugin.periodicallyShow(
        101, // ID for text periodic
        'اللهم ارحم أمي 🤍',
        bodyText,
        RepeatInterval.hourly,
        const NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: 'dua_${dua.id}',
        androidScheduleMode: AndroidScheduleMode.inexact,
      );
    }
  }

  // --- Audio Notifications Scheduling (Sequential Loop through all 16 audio recordings) ---
  Future<void> _scheduleAudioNotifications({
    required SettingsModel settings,
    required List<AudioAzkarModel> audioAzkar,
  }) async {
    if (audioAzkar.isEmpty) return;

    final int intervalMins = settings.getEffectiveAudioIntervalMinutes();
    final String motherName = settings.motherName;
    final now = DateTime.now();

    // If specific audio index (>0) selected, use that single audio.
    // Otherwise (0), cycle sequentially through all 16 audio recordings!
    final List<AudioAzkarModel> sequence = (settings.selectedAudioIndex > 0 &&
            settings.selectedAudioIndex <= audioAzkar.length)
        ? [audioAzkar[settings.selectedAudioIndex - 1]]
        : audioAzkar;

    for (int i = 0; i < sequence.length; i++) {
      final audioItem = sequence[i];
      final scheduledTime = now.add(Duration(minutes: intervalMins * (i + 1)));
      final tzScheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);

      final soundResource = audioItem.soundName; // e.g. 'audio1'
      final soundFileWithExt = '${audioItem.soundName}.mp3';

      final androidDetails = AndroidNotificationDetails(
        'azkar_audio_channel_$soundResource',
        'إشعار صوتي - ${audioItem.title}',
        channelDescription: 'قناة الإشعار الصوتي الخاص ${audioItem.title}',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(soundResource),
      );

      final iosDetails = DarwinNotificationDetails(
        presentSound: true,
        presentAlert: true,
        sound: soundFileWithExt,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final titleText = 'دعاء صبي لأمي $motherName 🎧';
      final bodyText = 'المقطع الصوتي #${audioItem.id}: ${audioItem.title}';

      await _notificationsPlugin.zonedSchedule(
        200 + i, // Unique notification ID per scheduled audio item
        titleText,
        bodyText,
        tzScheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'audio_${audioItem.id}',
      );
    }
  }

  // --- Trigger Instant Audio Test Notification ---
  Future<void> showInstantAudioNotification({
    required AudioAzkarModel audioItem,
    required String motherName,
  }) async {
    final soundResource = audioItem.soundName;
    final soundFileWithExt = '${audioItem.soundName}.mp3';

    final androidDetails = AndroidNotificationDetails(
      'azkar_instant_audio_channel_$soundResource',
      'إشعار تجربة الصوت',
      channelDescription: 'قناة تجربة أصوات الإشعارات الصوتية',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(soundResource),
    );

    final iosDetails = DarwinNotificationDetails(
      presentSound: true,
      presentAlert: true,
      sound: soundFileWithExt,
    );

    await _notificationsPlugin.show(
      998,
      audioItem.title,
      'إشعار تجريبي بصوت: ${audioItem.title} 🎧',
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: 'audio_${audioItem.id}',
    );
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
    bool playSound = true,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _textChannelId,
      _textChannelName,
      channelDescription: _textChannelDesc,
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
