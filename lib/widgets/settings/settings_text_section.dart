import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/app_colors.dart';
import '../../cubits/dua_cubit.dart';
import '../../cubits/settings_cubit.dart';
import '../../models/settings_model.dart';
import '../../services/notification_service.dart';
import '../../services/service_locator.dart';
import 'custom_interval_sheet.dart';
import 'settings_shared_widgets.dart';

class SettingsTextSection extends StatelessWidget {
  final SettingsModel settings;

  const SettingsTextSection({
    super.key,
    required this.settings,
  });

  String _formatIntervalText(int mins) {
    if (mins <= 0) return '1 دقيقة';
    if (mins < 60) return '$mins دقيقة';
    if (mins == 60) return 'ساعة واحدة';
    if (mins == 120) return 'ساعتين';
    if (mins % 60 == 0) return '${mins ~/ 60} ساعات';
    final h = mins ~/ 60;
    final m = mins % 60;
    return '$h ساعة و $m دقيقة';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader(
          title: '2. إشعارات الأدعية المكتوبة 📖',
          subtitle: 'التذكيرات النصية المكتوبة للأدعية الـ 30',
          icon: LucideIcons.bookOpenText,
        ),
        SizedBox(height: 12.h),
        SettingsCardContainer(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Material(
                color: Colors.transparent,
                child: SwitchListTile(
                  value: settings.isTextNotificationsEnabled,
                  activeTrackColor: AppColors.primary,
                  activeThumbColor: Colors.white,
                  thumbColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? Colors.white
                        : null,
                  ),
                  trackColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? AppColors.primary
                        : null,
                  ),
                  trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                  title: Text(
                    'تفعيل إشعارات الأدعية المكتوبة',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'إرسال تنبيهات نصية دورية للأدعية المكتوبة',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textHint,
                    ),
                  ),
                  onChanged: (val) async {
                    if (val) {
                      await sl<NotificationService>().setupEverything();
                    }
                    if (context.mounted) {
                      context.read<SettingsCubit>().toggleTextNotifications(val);
                    }
                  },
                ),
              ),
              if (settings.isTextNotificationsEnabled) ...[
                Divider(
                  height: 1,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
                ),
                Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    children: [
                      _buildTimeCard(
                        context: context,
                        intervalMins: settings.getEffectiveTextIntervalMinutes(),
                        isDark: isDark,
                      ),
                      SizedBox(height: 12.h),
                      SizedBox(
                        width: double.infinity,
                        height: 44.h,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          icon: Icon(LucideIcons.messageSquare, size: 18.r),
                          label: const Text('تجربة إشعار نصي فوري الآن 📖'),
                          onPressed: () async {
                            final duaCubit = context.read<DuaCubit>();
                            final duaList = duaCubit.state.duas;
                            if (duaList.isNotEmpty) {
                              final notificationService = sl<NotificationService>();
                              await notificationService.showInstantNotification(
                                title: 'اللهم ارحم أمي 🤍',
                                body: duaList.first.getFormattedText(settings.motherName),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeCard({
    required BuildContext context,
    required int intervalMins,
    required bool isDark,
  }) {
    final String intervalDisplay = _formatIntervalText(intervalMins);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkSurface, const Color(0xFF1B382B)]
              : [AppColors.surfaceVariant, Colors.white],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 14.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8.r,
                    ),
                  ],
                ),
                child: Icon(
                  LucideIcons.timer,
                  color: AppColors.accentGold,
                  size: 24.r,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الوقت الفاصل للتكرار الحالي:',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'إشعار جديد كل: $intervalDisplay ⚡',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 3,
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
              ),
              icon: Icon(LucideIcons.sliders, color: Colors.white, size: 20.r),
              label: Text(
                'تخصيص وتحديد الوقت بالدقائق ⏱️',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                CustomIntervalSheet.show(
                  context,
                  isAudio: false,
                  currentIntervalMins: intervalMins,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
