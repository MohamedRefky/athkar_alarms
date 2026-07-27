import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
                              hasCustomFile
                                  ? Container(
                                      constraints: BoxConstraints(maxHeight: 340.h),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24.r),
                                        border: Border.all(
                                          color: AppColors.primary.withValues(alpha: 0.35),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary
                                                .withValues(alpha: isDark ? 0.35 : 0.12),
                                            blurRadius: 20.r,
                                            spreadRadius: 1.r,
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(22.5.r),
                                        child: Image.file(
                                          File(customPath),
                                          fit: BoxFit.contain,
                                          filterQuality: FilterQuality.high,
                                          isAntiAlias: true,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      height: 340.h,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24.r),
                                        border: Border.all(
                                          color: AppColors.primary.withValues(alpha: 0.35),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary
                                                .withValues(alpha: isDark ? 0.35 : 0.12),
                                            blurRadius: 20.r,
                                            spreadRadius: 1.r,
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(22.5.r),
                                        child: Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: isDark
                                                  ? [
                                                      const Color(0xFF1B382B),
                                                      AppColors.darkSurface
                                                    ]
                                                  : [
                                                      AppColors.surfaceVariant,
                                                      Colors.white
                                                    ],
                                              begin: Alignment.topRight,
                                              end: Alignment.bottomLeft,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(22.r),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppColors.primary
                                                      .withValues(alpha: 0.12),
                                                  border: Border.all(
                                                    color: AppColors.accentGold
                                                        .withValues(alpha: 0.4),
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.volunteer_activism,
                                                  size: 80.r,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                              SizedBox(height: 14.h),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    LucideIcons.sparkles,
                                                    size: 18.r,
                                                    color: AppColors.accentGold,
                                                  ),
                                                  SizedBox(width: 6.w),
                                                  Text(
                                                    'صدقة جارية',
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
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
