import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/app_colors.dart';
import '../../cubits/dua_cubit.dart';
import '../../cubits/settings_cubit.dart';
import '../../models/settings_model.dart';
import '../../screens/audio_azkar_screen.dart';
import '../../services/notification_service.dart';
import '../../services/service_locator.dart';
import 'custom_interval_sheet.dart';
import 'lock_screen_permission_dialog.dart';
import 'settings_shared_widgets.dart';

class SettingsAudioSection extends StatelessWidget {
  final SettingsModel settings;

  const SettingsAudioSection({
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
          title: '1. الإشعارات والأدعية الصوتية 🎧',
          subtitle: 'تذكير صوتي دوري ينطق بالأدعية بصوت خاشع ومبارك',
          icon: LucideIcons.volume2,
        ),
        SizedBox(height: 12.h),
        SettingsCardContainer(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Material(
                color: Colors.transparent,
                child: SwitchListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                  value: settings.isAudioNotificationsEnabled,
                  activeTrackColor: AppColors.primary,
                  activeThumbColor: Colors.white,
                  title: Text(
                    'تفعيل الإشعارات الصوتية',
                    style: TextStyle(
                      fontSize: 15.5.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'تذكير دوري ينطق بالدعاء',
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
                      context.read<SettingsCubit>().toggleAudioNotifications(val);
                    }
                  },
                ),
              ),
              if (settings.isAudioNotificationsEnabled) ...[
                Divider(
                  height: 1,
                  indent: 16.w,
                  endIndent: 16.w,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Time Card
                      _buildTimeCard(
                        context: context,
                        intervalMins: settings.getEffectiveAudioIntervalMinutes(),
                        isDark: isDark,
                      ),
                      SizedBox(height: 16.h),

                      // 2. Target Selector
                      Text(
                        'فئة الأصوات',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      _buildTargetSelector(
                        context: context,
                        current: settings.audioGenderTarget,
                        isDark: isDark,
                      ),
                      SizedBox(height: 16.h),

                      // 3. Actions
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              icon: LucideIcons.listMusic,
                              label: 'المكتبة',
                              isPrimary: true,
                              isDark: isDark,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AudioAzkarScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: _buildActionButton(
                              icon: LucideIcons.bellRing,
                              label: 'تجربة صوتية',
                              isPrimary: false,
                              isDark: isDark,
                              onTap: () async {
                                final duaCubit = context.read<DuaCubit>();
                                final audioList = duaCubit.state.audioAzkar;
                                if (audioList.isNotEmpty) {
                                  final notificationService = sl<NotificationService>();
                                  await notificationService.showInstantAudioNotification(
                                    audioItem: audioList.first,
                                    motherName: settings.motherName,
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),

                      // Lock Screen Permissions
                      Center(
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor:
                                isDark ? AppColors.darkTextSecondary : AppColors.textHint,
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          ),
                          icon: Icon(LucideIcons.shieldCheck, size: 15.r, color: AppColors.accentGold),
                          label: Text(
                            'صلاحيات قفل الشاشة',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onPressed: () => LockScreenPermissionDialog.show(context),
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
                  isAudio: true,
                  currentIntervalMins: intervalMins,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetSelector({
    required BuildContext context,
    required AudioGenderTarget current,
    required bool isDark,
  }) {
    String getActiveDescription() {
      switch (current) {
        case AudioGenderTarget.femaleOnly:
          return 'تخصيص الإشعارات بنية الدعاء للمرحومة (7 مقاطع صوتية خاشعة بصيغة المؤنث للأم، الأخت، الجدة...)';
        case AudioGenderTarget.maleOnly:
          return 'تخصيص الإشعارات بنية الدعاء للمرحوم (8 مقاطع صوتية خاشعة بصيغة المذكر للأب، الأخ، الجد...)';
        case AudioGenderTarget.both:
          return 'التنويع والتناوب التلقائي بين كافة الأدعية والتسجيلات المباركة (15 مقطعاً صوتياً)';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkBackground
                : AppColors.surfaceVariant.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            children: [
              _buildSegmentPill(
                context: context,
                target: AudioGenderTarget.femaleOnly,
                current: current,
                label: 'المرحومة',
                icon: LucideIcons.heart,
                isDark: isDark,
              ),
              SizedBox(width: 4.w),
              _buildSegmentPill(
                context: context,
                target: AudioGenderTarget.maleOnly,
                current: current,
                label: 'المرحوم',
                icon: LucideIcons.user,
                isDark: isDark,
              ),
              SizedBox(width: 4.w),
              _buildSegmentPill(
                context: context,
                target: AudioGenderTarget.both,
                current: current,
                label: 'كافة الأصوات',
                icon: LucideIcons.volume2,
                isDark: isDark,
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.primary.withValues(alpha: 0.14)
                : AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                LucideIcons.info,
                size: 16.r,
                color: AppColors.primary,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  getActiveDescription(),
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentPill({
    required BuildContext context,
    required AudioGenderTarget target,
    required AudioGenderTarget current,
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = target == current;
    return Expanded(
      child: InkWell(
        onTap: () {
          context.read<SettingsCubit>().updateAudioGenderTarget(target);
        },
        borderRadius: BorderRadius.circular(12.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 8.r,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
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
              SizedBox(width: 5.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 44.h,
      child: isPrimary
          ? ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              icon: Icon(icon, size: 17.r),
              label: Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: onTap,
            )
          : OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              icon: Icon(icon, size: 17.r),
              label: Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: onTap,
            ),
    );
  }
}
