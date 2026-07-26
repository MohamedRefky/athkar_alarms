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
    // On Android, DateTime.now().timeZoneName returns abbreviations like 'EET'
    // which are NOT valid IANA timezone names. We need to find a matching
    // IANA timezone based on the device's actual UTC offset.
    final now = DateTime.now();
    final offset = now.timeZoneOffset;

    debugPrint('🕐 [TZ] Device timeZoneName: ${now.timeZoneName}');
    debugPrint('🕐 [TZ] Device UTC offset: ${offset.inHours}h ${offset.inMinutes % 60}m');

    // First try common IANA names for known offsets
    final knownTimezones = <int, String>{
      2: 'Africa/Cairo',       // UTC+2 (Egypt, EET)
      3: 'Asia/Riyadh',        // UTC+3 (Saudi, AST / EEST summer)
      4: 'Asia/Dubai',         // UTC+4
      5: 'Asia/Karachi',       // UTC+5
      1: 'Europe/London',      // UTC+1
      0: 'UTC',                // UTC+0
      -5: 'America/New_York',  // UTC-5
    };

    final offsetHours = offset.inHours;

    // Try the known mapping first
    if (knownTimezones.containsKey(offsetHours)) {
      try {
        tz.setLocalLocation(tz.getLocation(knownTimezones[offsetHours]!));
        debugPrint('🕐 [TZ] Set local timezone to: ${knownTimezones[offsetHours]} (from offset map)');
        return;
      } catch (_) {}
    }

    // Fallback: search all IANA timezones for one matching our offset
    try {
      final tzNow = DateTime.now().toUtc();
      for (final name in tz.timeZoneDatabase.locations.keys) {
        final location = tz.getLocation(name);
        final tzDateTime = tz.TZDateTime.from(tzNow, location);
        if (tzDateTime.timeZoneOffset == offset) {
          tz.setLocalLocation(location);
          debugPrint('🕐 [TZ] Set local timezone to: $name (from IANA search)');
          return;
        }
      }
    } catch (_) {}

    // Final fallback: Africa/Cairo
    try {
      tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
      debugPrint('🕐 [TZ] Set local timezone to: Africa/Cairo (fallback)');
    } catch (_) {
      debugPrint('🕐 [TZ] ⚠️ FAILED to set any local timezone!');
    }
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
          return AndroidScheduleMode.exactAllowWhileIdle;
        }
      } catch (_) {}
    }
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
    debugPrint('📋 [SCHEDULE] tz.local=${tz.local.name}, tz.now=${tz.TZDateTime.now(tz.local)}');

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
    final int intervalMins = settings.getEffectiveTextIntervalMinutes();
    final tzNow = tz.TZDateTime.now(tz.local);
    final scheduleMode = await _getScheduleMode();

    if (duas.isEmpty) return;

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

      await _notificationsPlugin.zonedSchedule(
        100, // ID for text daily
        'اللهم ارحم أمي 🤍',
        bodyText,
        tzScheduledDate,
        const NotificationDetails(android: androidDetails, iOS: iosDetails),
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'dua_${dua.id}',
      );
    } else {
      // Schedule multiple periodic text notifications based on intervalMins
      final shuffledDuas = List<DuaModel>.from(duas)..shuffle();
      final count = shuffledDuas.length.clamp(1, 10);

      for (int i = 0; i < count; i++) {
        final dua = shuffledDuas[i];
        final tzScheduledDate = tzNow.add(Duration(minutes: intervalMins * (i + 1)));
        final bodyText = dua.getFormattedText(motherName);
        debugPrint('📝 [TEXT] Scheduling notification #${110 + i} at $tzScheduledDate (in ${intervalMins * (i + 1)} min)');

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
          110 + i,
          'اللهم ارحم أمي 🤍',
          bodyText,
          tzScheduledDate,
          const NotificationDetails(android: androidDetails, iOS: iosDetails),
          androidScheduleMode: scheduleMode,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'dua_${dua.id}',
        );
      }
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
    final tzNow = tz.TZDateTime.now(tz.local);
    final scheduleMode = await _getScheduleMode();

    // If specific audio index (>0) selected, use that single audio.
    // Otherwise (0), cycle sequentially through all 16 audio recordings!
    final List<AudioAzkarModel> sequence = (settings.selectedAudioIndex > 0 &&
            settings.selectedAudioIndex <= audioAzkar.length)
        ? [audioAzkar[settings.selectedAudioIndex - 1]]
        : audioAzkar;

    for (int i = 0; i < sequence.length; i++) {
      final audioItem = sequence[i];
      final tzScheduledDate = tzNow.add(Duration(minutes: intervalMins * (i + 1)));
      debugPrint('🔊 [AUDIO] Scheduling notification #${200 + i} at $tzScheduledDate (in ${intervalMins * (i + 1)} min)');

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
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
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
