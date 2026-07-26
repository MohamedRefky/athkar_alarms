import 'package:flutter/material.dart';
import 'app/app.dart';
import 'services/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize GetIt dependency injection & services
  await initServiceLocator();

  runApp(const AzkarApp());
}
