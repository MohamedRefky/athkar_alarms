import 'dart:async';
import 'package:flutter/foundation.dart';
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
    _setLocalTimezone();

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

  void _setLocalTimezone() {
    final now = DateTime.now();
    final offset = now.timeZoneOffset;

    debugPrint('🕐 [TZ] Device timeZoneName: ${now.timeZoneName}');
    debugPrint('🕐 [TZ] Device UTC offset: ${offset.inHours}h ${offset.inMinutes % 60}m');

    final knownTimezones = <int, String>{
      2: 'Africa/Cairo',
      3: 'Asia/Riyadh',
      4: 'Asia/Dubai',
      5: 'Asia/Karachi',
      1: 'Europe/London',
      0: 'UTC',
      -5: 'America/New_York',
    };

    final offsetHours = offset.inHours;

    if (knownTimezones.containsKey(offsetHours)) {
      try {
        tz.setLocalLocation(tz.getLocation(knownTimezones[offsetHours]!));
        debugPrint('🕐 [TZ] Set timezone to: ${knownTimezones[offsetHours]}');
        return;
      } catch (_) {}
    }

    try {
      final tzNow = DateTime.now().toUtc();
      for (final name in tz.timeZoneDatabase.locations.keys) {
        final location = tz.getLocation(name);
        final tzDateTime = tz.TZDateTime.from(tzNow, location);
        if (tzDateTime.timeZoneOffset == offset) {
          tz.setLocalLocation(location);
          debugPrint('🕐 [TZ] Set timezone to: $name (IANA search)');
          return;
        }
      }
    } catch (_) {}

    try {
      tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
      debugPrint('🕐 [TZ] Set timezone to: Africa/Cairo (fallback)');
    } catch (_) {
      debugPrint('🕐 [TZ] ⚠️ FAILED to set any local timezone!');
    }
  }

  Future<void> _createNotificationChannels() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation == null) return;

    const textChannel = AndroidNotificationChannel(
      _textChannelId,
      _textChannelName,
      description: _textChannelDesc,
      importance: Importance.high,
      playSound: true,
    );
    await androidImplementation.createNotificationChannel(textChannel);

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

      try {
        await androidImplementation.requestExactAlarmsPermission();
      } catch (_) {}
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

  Future<AndroidScheduleMode> _getScheduleMode() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      try {
        final canExact = await androidImplementation.canScheduleExactNotifications() ?? false;
        if (canExact) {
          debugPrint('📋 [SCHEDULE] Using exactAllowWhileIdle mode');
          return AndroidScheduleMode.exactAllowWhileIdle;
        }
      } catch (_) {}
    }
    debugPrint('📋 [SCHEDULE] Using inexactAllowWhileIdle mode');
    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  Future<void> scheduleNotifications({
    required SettingsModel settings,
    required List<DuaModel> duas,
    List<AudioAzkarModel> audioAzkar = const [],
  }) async {
    debugPrint('📋 [SCHEDULE] ===== scheduleNotifications called =====');
    debugPrint('📋 [SCHEDULE] textEnabled=${settings.isTextNotificationsEnabled}, audioEnabled=${settings.isAudioNotificationsEnabled}');
    debugPrint('📋 [SCHEDULE] duas=${duas.length}, audioAzkar=${audioAzkar.length}');
    debugPrint('📋 [SCHEDULE] textInterval=${settings.getEffectiveTextIntervalMinutes()}min, audioInterval=${settings.getEffectiveAudioIntervalMinutes()}min');

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

    // Verify pending notifications
    final pending = await _notificationsPlugin.pendingNotificationRequests();
    debugPrint('📋 [SCHEDULE] ✅ Total pending notifications: ${pending.length}');
    for (final p in pending) {
      debugPrint('📋 [SCHEDULE]   → id=${p.id}, title=${p.title}');
    }
  }

  // --- Text Notifications Scheduling ---
  // Uses periodicallyShowWithDuration for reliable repeating delivery
  Future<void> _scheduleTextNotifications({
    required SettingsModel settings,
    required List<DuaModel> duas,
  }) async {
    final String motherName = settings.motherName;
    final int intervalMins = settings.getEffectiveTextIntervalMinutes();
    final scheduleMode = await _getScheduleMode();

    if (duas.isEmpty) return;

    final dua = (List<DuaModel>.from(duas)..shuffle()).first;
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

    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    debugPrint('📝 [TEXT] Using periodicallyShowWithDuration: every $intervalMins minutes');

    // Use periodicallyShowWithDuration - Android AlarmManager repeating
    // This fires the FIRST notification after intervalMins, then repeats
    await _notificationsPlugin.periodicallyShowWithDuration(
      110, // notification id
      'اللهم ارحم أمي 🤍',
      bodyText,
      Duration(minutes: intervalMins),
      details,
      androidScheduleMode: scheduleMode,
      payload: 'dua_${dua.id}',
    );

    debugPrint('📝 [TEXT] ✅ Periodic text notification scheduled (id=110, every ${intervalMins}min)');
  }

  // --- Audio Notifications Scheduling ---
  // Uses periodicallyShowWithDuration for reliable repeating delivery
  Future<void> _scheduleAudioNotifications({
    required SettingsModel settings,
    required List<AudioAzkarModel> audioAzkar,
  }) async {
    if (audioAzkar.isEmpty) return;

    final int intervalMins = settings.getEffectiveAudioIntervalMinutes();
    final String motherName = settings.motherName;
    final scheduleMode = await _getScheduleMode();

    // Pick the audio to use
    final AudioAzkarModel audioItem;
    if (settings.selectedAudioIndex > 0 &&
        settings.selectedAudioIndex <= audioAzkar.length) {
      audioItem = audioAzkar[settings.selectedAudioIndex - 1];
    } else {
      audioItem = audioAzkar.first;
    }

    final soundResource = audioItem.soundName;
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

    debugPrint('🔊 [AUDIO] Using periodicallyShowWithDuration: every $intervalMins minutes');

    // Use periodicallyShowWithDuration - Android AlarmManager repeating
    await _notificationsPlugin.periodicallyShowWithDuration(
      200, // notification id
      titleText,
      bodyText,
      Duration(minutes: intervalMins),
      details,
      androidScheduleMode: scheduleMode,
      payload: 'audio_${audioItem.id}',
    );

    debugPrint('🔊 [AUDIO] ✅ Periodic audio notification scheduled (id=200, every ${intervalMins}min)');
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
      'دعاء صبي لأمي $motherName 🎧',
      'إشعار تجريبي بصوت: ${audioItem.title} 🔊',
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
