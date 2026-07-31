import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/app_colors.dart';
import '../../screens/onboarding_screen.dart';

class SettingsDedicationFooterCard extends StatelessWidget {
  const SettingsDedicationFooterCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.heart, color: AppColors.accentGold, size: 24.r),
          SizedBox(height: 8.h),
          Text(
            'اللهم اغفر لأمنا وارحمها، واجعل هذا العمل صدقة جارية لها.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          OutlinedButton.icon(
            icon: Icon(LucideIcons.bookOpen, size: 16.r),
            label: const Text('قراءة سورة الفاتحة والإهداء'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const OnboardingScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
