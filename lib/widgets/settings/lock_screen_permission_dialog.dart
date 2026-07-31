import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../app/app_colors.dart';
import '../../services/notification_service.dart';
import '../../services/service_locator.dart';

class LockScreenPermissionDialog extends StatelessWidget {
  const LockScreenPermissionDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const LockScreenPermissionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.bellRing, color: AppColors.primary, size: 22.r),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'ضمان عمل الإشعارات عند قفل الشاشة 🔔',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'لضمان وصول صوت الأذكار في موعدها وقبل قفل الشاشة بدون أي تأخير:',
            style: TextStyle(
              fontSize: 13.5.sp,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.sparkles, color: AppColors.primary, size: 22.r),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'اضغط على زر التفعيل أدناه لمنح كافّة الأذونات المطلوبة تلقائياً بضغطة واحدة.',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 48.h,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 3,
                ),
                icon: Icon(LucideIcons.zap, size: 18.r),
                label: Text(
                  'تفعيل كافّة الأذونات',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  final notificationService = sl<NotificationService>();
                  final ok = await notificationService.setupEverything();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok
                              ? 'تم تفعيل جميع أذونات الإشعارات بنجاح ⚡'
                              : 'تم طلب الأذونات، يرجى تفعيل الأذونات عند ظهور رسائل النظام',
                        ),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 8.h),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                side: BorderSide(
                  color: (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)
                      .withValues(alpha: 0.4),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 10.h),
              ),
              icon: Icon(LucideIcons.settings, size: 16.r),
              label: Text(
                'إعدادات الهاتف ⚙️',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () async {
                Navigator.pop(context);
                await openAppSettings();
              },
            ),
          ],
        ),
      ],
    );
  }
}
