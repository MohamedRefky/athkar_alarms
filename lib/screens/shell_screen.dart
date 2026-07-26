import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../app/app_colors.dart';
import '../cubits/dua_cubit.dart';
import '../cubits/settings_cubit.dart';
import '../services/notification_service.dart';
import '../services/service_locator.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _currentIndex = 0;
  StreamSubscription? _notificationSub;

  final List<Widget> _pages = const [
    HomeScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _listenToNotificationPayloads();
  }

  void _listenToNotificationPayloads() {
    final notificationService = sl<NotificationService>();
    _notificationSub = notificationService.selectNotificationStream.stream.listen((payload) {
      if (payload != null && payload.startsWith('dua_')) {
        final idStr = payload.replaceFirst('dua_', '');
        final duaId = int.tryParse(idStr);
        if (duaId != null && mounted) {
          setState(() {
            _currentIndex = 0; // Switch to Home
          });
          final settings = context.read<SettingsCubit>().state.settings;
          context.read<DuaCubit>().selectDuaById(
                duaId,
                autoPlayAudio: settings.isAudioEnabled,
                customAudioMap: settings.customAudioMap,
              );
        }
      }
    });
  }

  @override
  void dispose() {
    _notificationSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
          indicatorColor: AppColors.primary.withValues(alpha: 0.15),
          elevation: 8,
          destinations: [
            NavigationDestination(
              icon: const Icon(LucideIcons.home),
              selectedIcon: const Icon(LucideIcons.home, color: AppColors.primary),
              label: 'الرئيسية',
            ),
            NavigationDestination(
              icon: const Icon(LucideIcons.settings),
              selectedIcon: const Icon(LucideIcons.settings, color: AppColors.primary),
              label: 'الإعدادات',
            ),
          ],
        ),
      ),
    );
  }
}
