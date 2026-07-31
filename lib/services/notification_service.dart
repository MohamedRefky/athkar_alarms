import 'dart:async';
import 'package:azkar/services/audio_service.dart';
import 'package:azkar/services/service_locator.dart';
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
  static const String _textChannelId = 'azkar_text_channel_v2';
  static const String _textChannelName = 'إشعارات الأدعية المكتوبة';
  static const String _textChannelDesc = 'تذكيرات دورية بالأدعية المكتوبة للأم المتوفاة';

  static const String _audioChannelPrefix = 'azkar_audio_v5_';

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
    await _logDiagnostics();
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

    // 1. Text Notification Channel
    try {
      const textChannel = AndroidNotificationChannel(
        _textChannelId,
        _textChannelName,
        description: _textChannelDesc,
        importance: Importance.max,
        playSound: true,
        audioAttributesUsage: AudioAttributesUsage.notification,
      );
      await androidImplementation.createNotificationChannel(textChannel);
      debugPrint('🔔 [CHANNELS] ✅ Text channel created');
    } catch (e) {
      debugPrint('🔔 [CHANNELS] ❌ FAILED to create text channel: $e');
    }

    // 2. Pre-create All Audio Sound Channels with Custom MP3 Sound & Max Importance
    final sounds = [
      'azkar_sound',
      for (int i = 1; i <= 7; i++) 'woman_mother_$i',
      for (int i = 1; i <= 3; i++) 'man_father_$i',
      for (int i = 1; i <= 5; i++) 'man_all_$i',
    ];

    int successCount = 0;
    int failCount = 0;

    for (final sound in sounds) {
      try {
        // Delete old cached channels so Android OS doesn't keep old sound preferences
        try {
          await androidImplementation.deleteNotificationChannel('azkar_audio_channel_v1');
          await androidImplementation.deleteNotificationChannel('azkar_audio_channel_$sound');
          await androidImplementation.deleteNotificationChannel('azkar_audio_v2_$sound');
          await androidImplementation.deleteNotificationChannel('azkar_audio_v3_$sound');
          await androidImplementation.deleteNotificationChannel('azkar_audio_v4_$sound');
          await androidImplementation.deleteNotificationChannel('$_audioChannelPrefix$sound');
          await androidImplementation.deleteNotificationChannel('azkar_instant_audio_channel_$sound');
        } catch (_) {}

        final audioChannel = AndroidNotificationChannel(
          '$_audioChannelPrefix$sound',
          'إشعار صوتي - $sound',
          description: 'قناة الإشعار الصوتي الخاص بالمقطع $sound',
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound(sound),
          audioAttributesUsage: AudioAttributesUsage.notification,
          enableVibration: true,
        );
        await androidImplementation.createNotificationChannel(audioChannel);
        successCount++;
        debugPrint('🔔 [CHANNELS] ✅ Created custom sound channel for: $sound');
      } catch (e) {
        failCount++;
        debugPrint('🔔 [CHANNELS] ❌ FAILED to create channel for "$sound": $e');
      }
    }

    debugPrint(
        '🔔 [CHANNELS] Done. Success=$successCount, Failed=$failCount out of ${sounds.length}');
  }

  /// Logs battery optimization / exact alarm status so device-specific
  /// issues (Xiaomi/Oppo/Huawei/Samsung restrictions) are visible in logs.
  Future<void> _logDiagnostics() async {
    try {
      final batteryStatus = await Permission.ignoreBatteryOptimizations.status;
      debugPrint('🔋 [DIAG] ignoreBatteryOptimizations status: $batteryStatus');
    } catch (e) {
      debugPrint('🔋 [DIAG] Could not read battery optimization status: $e');
    }

    try {
      final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
      debugPrint('⏰ [DIAG] scheduleExactAlarm status: $exactAlarmStatus');
    } catch (e) {
      debugPrint('⏰ [DIAG] Could not read exact alarm status: $e');
    }

    try {
      final notifStatus = await Permission.notification.status;
      debugPrint('🔔 [DIAG] notification permission status: $notifStatus');
    } catch (e) {
      debugPrint('🔔 [DIAG] Could not read notification permission status: $e');
    }
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
      if (await Permission.ignoreBatteryOptimizations.isDenied) {
        final batteryStatus = await Permission.ignoreBatteryOptimizations.request();
        debugPrint('🔔 [PERM] Battery optimization permission status: $batteryStatus');
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

    await _logDiagnostics();
    return granted;
  }

  /// نداء واحد بسيط يطلب كل الأذونات المطلوبة ورا بعض من غير ما اليوزر
  /// يحتاج يفهم أي حاجة تقنية. مناسب لزرار واحد في الواجهة زي
  /// "فعّل التنبيهات".
  Future<bool> setupEverything() async {
    debugPrint('🚀 [SETUP] Starting one-tap permission setup...');

    // 1. إذن الإشعارات نفسه (Android 13+ / iOS)
    final notificationsOk = await requestPermissions();
    debugPrint('🚀 [SETUP] Notifications permission granted: $notificationsOk');

    // 2. إذن التنبيه الدقيق (عشان الإشعار ييجي في وقته بالظبط)
    await requestExactAlarmPermission();

    // 3. تجاهل توفير البطارية (عشان النظام مايوقفش التطبيق في الخلفية)
    await requestIgnoreBatteryOptimizations();

    await _logDiagnostics();
    debugPrint('🚀 [SETUP] ✅ One-tap setup finished');

    return notificationsOk;
  }

  Future<bool> requestIgnoreBatteryOptimizations() async {
    try {
      final status = await Permission.ignoreBatteryOptimizations.request();
      debugPrint('🔔 [PERM] Direct battery optimization request status: $status');
      return status.isGranted;
    } catch (e) {
      debugPrint('🔔 [PERM] Error requesting ignoreBatteryOptimizations: $e');
      return false;
    }
  }

  Future<bool> requestExactAlarmPermission() async {
    try {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestExactAlarmsPermission();
      }
      final status = await Permission.scheduleExactAlarm.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('🔔 [PERM] Error requesting scheduleExactAlarm: $e');
      return false;
    }
  }

  Future<AndroidScheduleMode> _getScheduleMode() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      try {
        final canExact = await androidImplementation.canScheduleExactNotifications() ?? false;
        if (canExact) {
          debugPrint('📋 [SCHEDULE] Using alarmClock mode for exact background wakeup');
          return AndroidScheduleMode.alarmClock;
        }
      } catch (e) {
        debugPrint('📋 [SCHEDULE] Error checking canScheduleExactNotifications: $e');
      }
    }
    debugPrint('📋 [SCHEDULE] Using inexactAllowWhileIdle mode fallback');
    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  Future<void> scheduleNotifications({
    required SettingsModel settings,
    required List<DuaModel> duas,
    List<AudioAzkarModel> audioAzkar = const [],
    bool onlyIfEmpty = false,
  }) async {
    debugPrint('📋 [SCHEDULE] ===== scheduleNotifications called (onlyIfEmpty=$onlyIfEmpty) =====');

    await _createNotificationChannels();

    if (onlyIfEmpty) {
      final pendingCount = (await _notificationsPlugin.pendingNotificationRequests()).length;
      if (pendingCount > 0) {
        debugPrint('📋 [SCHEDULE] ⏩ Already has $pendingCount pending notifications. Skipping reschedule.');
        return;
      }
    }

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
      audioAttributesUsage: AudioAttributesUsage.notification,
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.reminder,
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

    int scheduled = 0;

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
        scheduled++;
      } catch (e) {
        debugPrint('📝 [TEXT] Error scheduling notification $notificationId with $scheduleMode: $e. Retrying fallback.');
        try {
          await _notificationsPlugin.zonedSchedule(
            notificationId,
            'اللهم ارحم أمي 🤍',
            bodyText,
            scheduledDate,
            details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: 'dua_${dua.id}',
          );
          scheduled++;
        } catch (e2) {
          debugPrint('📝 [TEXT] Fallback error scheduling notification $notificationId: $e2');
        }
      }
    }

    debugPrint('📝 [TEXT] ✅ Successfully scheduled $scheduled/$count text notifications');
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

    // Filter audio pool according to user's gender preference (femaleOnly / maleOnly / both)
    List<AudioAzkarModel> pool = audioAzkar;
    if (settings.audioGenderTarget == AudioGenderTarget.femaleOnly) {
      pool = audioAzkar.where((a) => a.isFemale).toList();
    } else if (settings.audioGenderTarget == AudioGenderTarget.maleOnly) {
      pool = audioAzkar.where((a) => a.isMale).toList();
    }
    if (pool.isEmpty) {
      pool = audioAzkar;
    }

    // Shuffle audio list for random order if auto-rotation is selected
    final shuffledAudio = List<AudioAzkarModel>.from(pool)..shuffle();

    debugPrint('🔊 [AUDIO] Scheduling $count exact audio notifications every $intervalMins min (target: ${settings.audioGenderTarget.name}, pool size: ${pool.length})');

    int scheduled = 0;

    for (int i = 1; i <= count; i++) {
      final AudioAzkarModel audioItem;
      if (settings.selectedAudioIndex > 0) {
        final specific = audioAzkar.firstWhere(
          (a) => a.id == settings.selectedAudioIndex,
          orElse: () => shuffledAudio[(i - 1) % shuffledAudio.length],
        );
        audioItem = specific;
      } else {
        // Rotate through filtered audio files automatically
        audioItem = shuffledAudio[(i - 1) % shuffledAudio.length];
      }

      const soundResource = 'azkar_sound';
      final soundFileWithExt = '${audioItem.soundName}.mp3';

      final androidDetails = AndroidNotificationDetails(
        '${_audioChannelPrefix}azkar_sound',
        'إشعار صوتي - ${audioItem.title}',
        channelDescription: 'قناة الإشعار الصوتي الخاص ${audioItem.title}',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound(soundResource),
        audioAttributesUsage: AudioAttributesUsage.notification,
        visibility: NotificationVisibility.public,
        category: AndroidNotificationCategory.reminder,
        enableVibration: true,
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
        scheduled++;
      } catch (e) {
        debugPrint('🔊 [AUDIO] Error with $scheduleMode: $e. Retrying fallback.');
        try {
          await _notificationsPlugin.zonedSchedule(
            notificationId,
            titleText,
            bodyText,
            scheduledDate,
            details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: 'audio_${audioItem.id}',
          );
          scheduled++;
        } catch (e2) {
          debugPrint('🔊 [AUDIO] Fallback error scheduling notification $notificationId: $e2');
        }
      }
    }

    debugPrint('🔊 [AUDIO] ✅ Successfully scheduled $scheduled/$count audio notifications with rotation');
  }

  // --- Trigger Instant Audio Test Notification ---
  Future<void> showInstantAudioNotification({
    required AudioAzkarModel audioItem,
    required String motherName,
  }) async {
    await _createNotificationChannels();

    // Play the full audio recitation voice via AudioService
    try {
      final audioService = sl<AudioService>();
      await audioService.playAsset(audioItem.audio);
    } catch (_) {}

    const soundResource = 'azkar_sound';
    final soundFileWithExt = '${audioItem.soundName}.mp3';

    final androidDetails = AndroidNotificationDetails(
      '${_audioChannelPrefix}azkar_sound',
      'إشعار تجربة الصوت',
      channelDescription: 'قناة تجربة أصوات الإشعارات الصوتية',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound(soundResource),
      audioAttributesUsage: AudioAttributesUsage.notification,
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.reminder,
      enableVibration: true,
    );

    final iosDetails = DarwinNotificationDetails(
      presentSound: true,
      presentAlert: true,
      sound: soundFileWithExt,
    );

    try {
      await _notificationsPlugin.show(
        998,
        'دعاء لأمي $motherName 🎧',
        'إشعار تجريبي بصوت: ${audioItem.title} 🔊',
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: 'audio_${audioItem.id}',
      );
      debugPrint('🔊 [TEST] Instant audio notification shown for: $soundResource');
    } catch (e) {
      debugPrint('🔊 [TEST] ❌ FAILED to show instant audio notification for "$soundResource": $e');
    }
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