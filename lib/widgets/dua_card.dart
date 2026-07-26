import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../app/app_colors.dart';

class DuaCard extends StatelessWidget {
  final String formattedText;
  final String motherName;
  final bool isPlayingAudio;
  final VoidCallback onToggleAudio;
  final VoidCallback onNextDua;

  const DuaCard({
    super.key,
    required this.formattedText,
    required this.motherName,
    required this.isPlayingAudio,
    required this.onToggleAudio,
    required this.onNextDua,
  });

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: formattedText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'تم نسخ الدعاء بنجاح',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Zain', fontSize: 16),
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 4,
      shadowColor: AppColors.cardShadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
        side: BorderSide(
          color: AppColors.accentGold.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Badge & Ornament
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.heartHandshake,
                  color: AppColors.accentGold,
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    motherName.trim().isNotEmpty
                        ? 'دعاء لـ $motherName'
                        : 'دعاء لأمي',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Dua Text Content
            SelectableText(
              formattedText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.sp,
                height: 1.7,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),

            SizedBox(height: 28.h),

            // Decorative Divider
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: AppColors.accentGold.withValues(alpha: 0.2),
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
                    color: AppColors.accentGold.withValues(alpha: 0.2),
                    thickness: 1,
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Card Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Copy Button
                IconButton.filledTonal(
                  onPressed: () => _copyToClipboard(context),
                  icon: const Icon(LucideIcons.copy),
                  tooltip: 'نسخ النص',
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  ),
                ),

                // Audio Play Button
                IconButton.filled(
                  onPressed: onToggleAudio,
                  iconSize: 28.sp,
                  icon: Icon(
                    isPlayingAudio ? LucideIcons.square : LucideIcons.volume2,
                  ),
                  tooltip: isPlayingAudio ? 'إيقاف الصوت' : 'تشغيل الصوت',
                  style: IconButton.styleFrom(
                    backgroundColor: isPlayingAudio
                        ? AppColors.error
                        : AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.all(16.r),
                  ),
                ),

                // Refresh / Next Dua Button
                IconButton.filledTonal(
                  onPressed: onNextDua,
                  icon: const Icon(LucideIcons.refreshCw),
                  tooltip: 'دعاء جديد',
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
