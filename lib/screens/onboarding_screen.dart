import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../app/app_colors.dart';
import '../cubits/settings_cubit.dart';
import '../cubits/settings_state.dart';
import '../widgets/surah_fatiha_card.dart';
import 'shell_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ShellScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settingsState) {
            final motherName = settingsState.settings.motherName.trim();
            final hasCustomName = motherName.isNotEmpty;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                children: [
                  SizedBox(height: 12.h),

                  // Decorative Top Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(30.r),
                      border: Border.all(
                        color: AppColors.accentGold.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.heart,
                          size: 16.r,
                          color: AppColors.accentGold,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'صدقة جارية',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentGold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Dedication Title & Name Section
                  Text(
                    hasCustomName ? 'صدقة جارية عن روح' : 'صدقة جارية عن جميع أمواتنا',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (hasCustomName) ...[
                    SizedBox(height: 8.h),
                    Text(
                      motherName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.primaryDark,
                        height: 1.3,
                      ),
                    ),
                  ],
                  SizedBox(height: 12.h),
                  Text(
                    hasCustomName
                        ? 'نرجو الفاتحة والدعاء بالرحمة والمغفرة'
                        : 'نرجو الفاتحة والدعاء لجميع أموات المسلمين بالرحمة والمغفرة',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentGold,
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Surah Al-Fatiha Card Component
                  const Expanded(
                    child: SurahFatihaCard(),
                  ),

                  SizedBox(height: 20.h),

                  // Action Button - Navigate to Main App
                  SizedBox(
                    width: double.infinity,
                    height: 54.h,
                    child: ElevatedButton(
                      onPressed: () => _navigateToHome(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 4,
                        shadowColor: AppColors.primary.withValues(alpha: 0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'الدخول إلى التطبيق',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.arrow_forward,
                            size: 20.r,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 8.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
