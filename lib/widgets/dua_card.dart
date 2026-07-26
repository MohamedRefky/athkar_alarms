import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../app/app_colors.dart';

class DuaCard extends StatefulWidget {
  final String formattedText;
  final String motherName;
  final VoidCallback onNextDua;

  const DuaCard({
    super.key,
    required this.formattedText,
    required this.motherName,
    required this.onNextDua,
  });

  @override
  State<DuaCard> createState() => _DuaCardState();
}

class _DuaCardState extends State<DuaCard> {
  int _prayCount = 0;

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.formattedText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.checkCheck, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              'تم نسخ الدعاء المبارك بنجاح',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  void _incrementPrayCount() {
    setState(() {
      _prayCount++;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.heart, color: AppColors.accentGold, size: 18),
            const SizedBox(width: 8),
            Text(
              'تقبل الله دعاءك بالرحمة والمغفرة 🤲',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryDark,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: 20.r,
            spreadRadius: 2.r,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Header Badge inside Card
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.bookOpenText,
                        color: AppColors.primary,
                        size: 16.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'دعاء مبارك مستجاب 🤲',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Opening Quote
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '❝',
                  style: TextStyle(
                    fontSize: 32.sp,
                    color: AppColors.accentGold.withValues(alpha: 0.6),
                    height: 0.8,
                  ),
                ),
              ],
            ),

            // Main Dua Text
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: SelectableText(
                widget.formattedText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 23.sp,
                  height: 1.8,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
            ),

            // Closing Quote
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '❞',
                  style: TextStyle(
                    fontSize: 32.sp,
                    color: AppColors.accentGold.withValues(alpha: 0.6),
                    height: 0.8,
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // "آمين" Button Directly Under the Dua Text
            GestureDetector(
              onTap: _incrementPrayCount,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF2A3D34), AppColors.darkSurface]
                        : [AppColors.accentGold.withValues(alpha: 0.18), Colors.white],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: AppColors.accentGold.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentGold.withValues(alpha: 0.15),
                      blurRadius: 10.r,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.heart,
                      color: AppColors.accentGold,
                      size: 20.r,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'آمين يارب العالمين 🤲 ${_prayCount > 0 ? "($_prayCount)" : ""}',
                      style: TextStyle(
                        color: isDark ? AppColors.accentGold : const Color(0xFFB58428),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // Decorative Divider with Islamic Symbol
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: AppColors.accentGold.withValues(alpha: 0.25),
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Text(
                    '۞',
                    style: TextStyle(
                      color: AppColors.accentGold,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: AppColors.accentGold.withValues(alpha: 0.25),
                    thickness: 1,
                  ),
                ),
              ],
            ),

            SizedBox(height: 18.h),

            // Card Action Bar (Copy & Next Dua)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Copy Button
                _buildActionButton(
                  icon: LucideIcons.copy,
                  label: 'نسخ الدعاء',
                  onPressed: () => _copyToClipboard(context),
                  color: AppColors.primary,
                  isDark: isDark,
                ),

                // Refresh / Next Dua Button
                _buildActionButton(
                  icon: LucideIcons.refreshCw,
                  label: 'دعاء آخر',
                  onPressed: widget.onNextDua,
                  color: AppColors.primary,
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: color.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(icon, color: color, size: 22.r),
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
