import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/app_colors.dart';

class AudioAzkarFilterBar extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  const AudioAzkarFilterBar({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            _FilterTab(
              id: 'all',
              title: 'كافة الأصوات',
              icon: LucideIcons.layers,
              isSelected: activeFilter == 'all',
              onTap: () => onFilterChanged('all'),
            ),
            _FilterTab(
              id: 'female',
              title: 'أدعية المرحومة',
              icon: LucideIcons.heart,
              isSelected: activeFilter == 'female',
              onTap: () => onFilterChanged('female'),
            ),
            _FilterTab(
              id: 'male',
              title: 'أدعية المرحوم',
              icon: LucideIcons.userCheck,
              isSelected: activeFilter == 'male',
              onTap: () => onFilterChanged('male'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String id;
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.id,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15.r,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
              ),
              SizedBox(width: 6.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
