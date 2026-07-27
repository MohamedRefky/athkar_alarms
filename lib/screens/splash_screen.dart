import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app/app_colors.dart';
import '../cubits/settings_cubit.dart';
import '../cubits/settings_state.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();

    // Auto-navigate to OnboardingScreen after 3 seconds
    _timer = Timer(const Duration(milliseconds: 3000), () {
      _navigateToOnboarding();
    });
  }

  void _navigateToOnboarding() {
    if (!mounted) return;
    _timer?.cancel();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const OnboardingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: GestureDetector(
        onTap: _navigateToOnboarding, // Allow tapping to skip splash
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 12.h),
                      // Large Elegant Emblem Icon or Custom Framed Image
                      BlocBuilder<SettingsCubit, SettingsState>(
                        builder: (context, settingsState) {
                          final customPath =
                              settingsState.settings.customSplashImagePath;
                          final bool hasCustomFile = customPath != null &&
                              customPath.isNotEmpty &&
                              File(customPath).existsSync();
                          final motherName = settingsState.settings.motherName.trim();

                          final splashTitle = motherName.isNotEmpty
                              ? 'اللهم ارحم $motherName 🤍'
                              : 'اللهم ارحم موتانا وموتى المسلمين';

                          return Column(
                            children: [
                              Container(
                                width: 210.r,
                                height: 210.r,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: SweepGradient(
                                    colors: [
                                      AppColors.accentGold,
                                      AppColors.primary,
                                      AppColors.primaryDark,
                                      AppColors.accentGold,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: isDark ? 0.5 : 0.25),
                                      blurRadius: 28.r,
                                      spreadRadius: 4.r,
                                    ),
                                    BoxShadow(
                                      color: AppColors.accentGold.withValues(alpha: 0.3),
                                      blurRadius: 18.r,
                                      spreadRadius: 1.r,
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(4.r),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDark ? AppColors.darkSurface : Colors.white,
                                  ),
                                  child: ClipOval(
                                    child: hasCustomFile
                                        ? Image.file(
                                            File(customPath),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                            filterQuality: FilterQuality.high,
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: isDark
                                                    ? [const Color(0xFF1B382B), AppColors.darkSurface]
                                                    : [AppColors.surfaceVariant, Colors.white],
                                                begin: Alignment.topRight,
                                                end: Alignment.bottomLeft,
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.volunteer_activism,
                                                  size: 72.r,
                                                  color: AppColors.primary,
                                                ),
                                                SizedBox(height: 6.h),
                                                Icon(
                                                  Icons.auto_awesome,
                                                  size: 20.r,
                                                  color: AppColors.accentGold,
                                                ),
                                              ],
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 28.h),
                              Text(
                                splashTitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 26.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.primaryDark,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                'صدقة جارية 🕊️',
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  color: AppColors.accentGold,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 24.h),
                      // Subtle skip indicator
                      Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'اضغط للمتابعة',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.arrow_back_ios_new,
                              size: 13.r,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
