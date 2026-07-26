import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../app/app_colors.dart';
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
        child: Padding(
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
                'صدقة جارية عن المرحومة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'صباح عجمي أحمد محمد ريان',
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
              SizedBox(height: 12.h),
              Text(
                'نرجو الفاتحة والدعاء لها بالرحمة والمغفرة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentGold,
                ),
              ),

              SizedBox(height: 20.h),

              // Surah Al-Fatiha Card
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.surface,
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(
                      color: isDark
                          ? AppColors.primaryLight.withValues(alpha: 0.2)
                          : AppColors.primary.withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                        blurRadius: 16.r,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // Decorative Header Icon
                        Icon(
                          LucideIcons.bookOpen,
                          size: 28.r,
                          color: AppColors.primary,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'سُورَةُ الفَاتِحَةِ',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.primaryDark,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Divider(
                          color: AppColors.accentGold.withValues(alpha: 0.3),
                          thickness: 1,
                          indent: 40.w,
                          endIndent: 40.w,
                        ),
                        SizedBox(height: 16.h),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 19.sp,
                              fontWeight: FontWeight.w600,
                              height: 2.2,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                            children: const [
                              TextSpan(text: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ '),
                              TextSpan(
                                text: '﴿١﴾ ',
                                style: TextStyle(
                                  color: AppColors.accentGold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(text: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ '),
                              TextSpan(
                                text: '﴿٢﴾ ',
                                style: TextStyle(
                                  color: AppColors.accentGold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(text: 'الرَّحْمَٰنِ الرَّحِيمِ '),
                              TextSpan(
                                text: '﴿٣﴾ ',
                                style: TextStyle(
                                  color: AppColors.accentGold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(text: 'مَالِكِ يَوْمِ الدِّينِ '),
                              TextSpan(
                                text: '﴿٤﴾ ',
                                style: TextStyle(
                                  color: AppColors.accentGold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(text: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ '),
                              TextSpan(
                                text: '﴿٥﴾ ',
                                style: TextStyle(
                                  color: AppColors.accentGold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(text: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ '),
                              TextSpan(
                                text: '﴿٦﴾ ',
                                style: TextStyle(
                                  color: AppColors.accentGold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text:
                                    'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ ',
                              ),
                              TextSpan(
                                text: '﴿٧﴾',
                                style: TextStyle(
                                  color: AppColors.accentGold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
        ),
      ),
    );
  }
}
