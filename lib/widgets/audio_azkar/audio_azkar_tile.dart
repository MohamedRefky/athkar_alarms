import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/app_colors.dart';
import '../../cubits/dua_cubit.dart';
import '../../cubits/settings_cubit.dart';
import '../../models/audio_azkar_model.dart';
import '../../services/notification_service.dart';
import '../../services/service_locator.dart';

class AudioAzkarTile extends StatelessWidget {
  final AudioAzkarModel item;
  final bool isCurrentPlaying;
  final bool isSelectedForNotification;
  final String motherName;

  const AudioAzkarTile({
    super.key,
    required this.item,
    required this.isCurrentPlaying,
    required this.isSelectedForNotification,
    required this.motherName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isSelectedForNotification
              ? AppColors.primary
              : (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05)),
          width: isSelectedForNotification ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 6.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 6.h,
          ),
          leading: GestureDetector(
            onTap: () => context.read<DuaCubit>().playAudioAzkarItem(item),
            child: Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: isCurrentPlaying
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCurrentPlaying ? LucideIcons.pause : LucideIcons.play,
                color: isCurrentPlaying ? Colors.white : AppColors.primary,
                size: 22.r,
              ),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.isFemale ? LucideIcons.heart : LucideIcons.userCheck,
                      size: 11.r,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      item.isFemale ? 'للمرحومة' : 'للمرحوم',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              isSelectedForNotification
                  ? 'محدد كنغمة إشعارات صوتية أساسية ✓'
                  : 'اضغط للاستماع أو التجربة',
              style: TextStyle(
                fontSize: 12.sp,
                color: isSelectedForNotification ? AppColors.primary : AppColors.textHint,
                fontWeight: isSelectedForNotification ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'تجربة إشعار فورية بصوت المقطع',
                icon: Icon(
                  LucideIcons.bellRing,
                  color: AppColors.primary,
                  size: 20.r,
                ),
                onPressed: () {
                  sl<NotificationService>().showInstantAudioNotification(
                    audioItem: item,
                    motherName: motherName,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم إرسال إشعار تجريبي بصوت: ${item.title}'),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  LucideIcons.moreVertical,
                  color: AppColors.textHint,
                  size: 18.r,
                ),
                onSelected: (val) {
                  if (val == 'select') {
                    context.read<SettingsCubit>().updateSelectedAudioIndex(item.id);
                    final duaCubit = context.read<DuaCubit>();
                    context.read<SettingsCubit>().rescheduleNotifications(
                          duas: duaCubit.state.duas,
                          audioAzkar: duaCubit.state.audioAzkar,
                        );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'select',
                    child: Row(
                      children: [
                        Icon(LucideIcons.checkCircle, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('تعيين كصوت الإشعارات المفضل'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
