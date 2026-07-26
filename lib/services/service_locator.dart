import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'preferences_service.dart';
import 'audio_service.dart';
import 'notification_service.dart';

final GetIt sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // SharedPreferences
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPrefs);
  sl.registerSingleton<PreferencesService>(PreferencesService(sl()));

  // Audio Service
  sl.registerSingleton<AudioService>(AudioService());

  // Notification Service
  final notificationService = NotificationService();
  await notificationService.init();
  sl.registerSingleton<NotificationService>(notificationService);
}
