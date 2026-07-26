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
    _notificationSub =
        notificationService.selectNotificationStream.stream.listen((payload) {
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
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildFloatingNavBar(context, isDark),
    );
  }

  Widget _buildFloatingNavBar(BuildContext context, bool isDark) {
    return SafeArea(
      child: Container(
        height: 62.h,
        margin: EdgeInsets.only(left: 32.w, right: 32.w, bottom: 16.h),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(32.r),
          border: Border.all(
            color: AppColors.accentGold.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.15),
              blurRadius: 20.r,
              spreadRadius: 1.r,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              icon: LucideIcons.home,
              label: 'الرئيسية',
              isDark: isDark,
            ),
            _buildNavItem(
              index: 1,
              icon: LucideIcons.settings,
              label: 'الإعدادات',
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    final isSelected = _currentIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _currentIndex = index;
            });
          },
          borderRadius: BorderRadius.circular(24.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 22.w : 16.w,
              vertical: 8.h,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8.r,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20.r,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary),
                ),
                if (isSelected) ...[
                  SizedBox(width: 8.w),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
