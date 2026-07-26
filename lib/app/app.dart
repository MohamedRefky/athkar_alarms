import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubits/settings_cubit.dart';
import '../cubits/dua_cubit.dart';
import '../services/service_locator.dart';
import '../screens/shell_screen.dart';
import 'app_theme.dart';

class AzkarApp extends StatelessWidget {
  const AzkarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<SettingsCubit>(
              create: (_) => SettingsCubit(sl(), sl()),
            ),
            BlocProvider<DuaCubit>(
              create: (_) => DuaCubit(sl(), sl())..loadDuas(),
            ),
          ],
          child: MaterialApp(
            title: 'اللهم ارحم أمي',
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.system,
            theme: AppTheme.lightTheme(context),
            darkTheme: AppTheme.darkTheme(context),
            locale: const Locale('ar', 'EG'),
            supportedLocales: const [
              Locale('ar', 'EG'),
              Locale('en', 'US'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const ShellScreen(),
          ),
        );
      },
    );
  }
}
