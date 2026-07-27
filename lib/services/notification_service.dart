import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
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
      importance: Importance.max,
      playSound: true,
    );
    await androidImplementation.createNotificationChannel(textChannel);

    const audioChannel = AndroidNotificationChannel(
      _audioChannelId,
      _audioChannelName,
      description: _audioChannelDesc,
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('azkar_sound'),
    );
    await androidImplementation.createNotificationChannel(audioChannel);
  }

  Future<bool> requestPermissions() async {
    // 1. Request via permission_handler (triggers system dialogs on Android 13+)
    try {
      final notifStatus = await Permission.notification.request();
      debugPrint('🔔 [PERM] Notification permission status: $notifStatus');
      if (await Permission.scheduleExactAlarm.isDenied) {
        final alarmStatus = await Permission.scheduleExactAlarm.request();
        debugPrint('🔔 [PERM] Exact Alarm permission status: $alarmStatus');
      }
    } catch (e) {
      debugPrint('🔔 [PERM] Error with permission_handler: $e');
    }

    // 2. Fallback via flutter_local_notifications plugin
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
  // Uses zonedSchedule with exactAllowWhileIdle for exact delivery timing
  Future<void> _scheduleTextNotifications({
    required SettingsModel settings,
    required List<DuaModel> duas,
  }) async {
    final String motherName = settings.motherName;
    final int intervalMins = settings.getEffectiveTextIntervalMinutes();
    final scheduleMode = await _getScheduleMode();

    if (duas.isEmpty) return;

    const androidDetails = AndroidNotificationDetails(
      _textChannelId,
      _textChannelName,
      channelDescription: _textChannelDesc,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentSound: true,
      presentAlert: true,
      presentBadge: true,
    );

    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    final now = tz.TZDateTime.now(tz.local);
    final shuffledDuas = List<DuaModel>.from(duas)..shuffle();
    const int count = 25;

    debugPrint('📝 [TEXT] Scheduling $count exact text notifications every $intervalMins min');

    for (int i = 1; i <= count; i++) {
      final dua = shuffledDuas[(i - 1) % shuffledDuas.length];
      final bodyText = dua.getFormattedText(motherName);
      final scheduledDate = now.add(Duration(minutes: intervalMins * i));
      final notificationId = 100 + i;

      try {
        await _notificationsPlugin.zonedSchedule(
          notificationId,
          'اللهم ارحم أمي 🤍',
          bodyText,
          scheduledDate,
          details,
          androidScheduleMode: scheduleMode,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'dua_${dua.id}',
        );
      } catch (e) {
        debugPrint('📝 [TEXT] Error scheduling notification $notificationId: $e');
      }
    }

    debugPrint('📝 [TEXT] ✅ Successfully scheduled $count exact text notifications');
  }

  // --- Audio Notifications Scheduling ---
  // Uses zonedSchedule with exactAllowWhileIdle for exact delivery timing
  Future<void> _scheduleAudioNotifications({
    required SettingsModel settings,
    required List<AudioAzkarModel> audioAzkar,
  }) async {
    if (audioAzkar.isEmpty) return;

    final int intervalMins = settings.getEffectiveAudioIntervalMinutes();
    final String motherName = settings.motherName;
    final scheduleMode = await _getScheduleMode();

    final now = tz.TZDateTime.now(tz.local);
    const int count = 25;

    // Shuffle audio list for random order if auto-rotation is selected
    final shuffledAudio = List<AudioAzkarModel>.from(audioAzkar)..shuffle();

    debugPrint('🔊 [AUDIO] Scheduling $count exact audio notifications every $intervalMins min');

    for (int i = 1; i <= count; i++) {
      final AudioAzkarModel audioItem;
      if (settings.selectedAudioIndex > 0 &&
          settings.selectedAudioIndex <= audioAzkar.length) {
        // Specific audio file chosen by user
        audioItem = audioAzkar[settings.selectedAudioIndex - 1];
      } else {
        // Rotate through all audio files automatically
        audioItem = shuffledAudio[(i - 1) % shuffledAudio.length];
      }

      final soundResource = audioItem.soundName;
      final soundFileWithExt = '${audioItem.soundName}.mp3';

      final androidDetails = AndroidNotificationDetails(
        'azkar_audio_channel_$soundResource',
        'إشعار صوتي - ${audioItem.title}',
        channelDescription: 'قناة الإشعار الصوتي الخاص ${audioItem.title}',
        importance: Importance.max,
        priority: Priority.max,
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

      final titleText = 'دعاء لأمي $motherName 🎧';
      final bodyText = '${audioItem.title} 🔊';

      final scheduledDate = now.add(Duration(minutes: intervalMins * i));
      final notificationId = 200 + i;

      try {
        await _notificationsPlugin.zonedSchedule(
          notificationId,
          titleText,
          bodyText,
          scheduledDate,
          details,
          androidScheduleMode: scheduleMode,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'audio_${audioItem.id}',
        );
      } catch (e) {
        debugPrint('🔊 [AUDIO] Error scheduling audio notification $notificationId: $e');
      }
    }

    debugPrint('🔊 [AUDIO] ✅ Successfully scheduled $count exact audio notifications with rotation');
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
