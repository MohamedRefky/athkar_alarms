import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../app/app_colors.dart';
import '../cubits/dua_cubit.dart';
import '../cubits/dua_state.dart';
import '../cubits/settings_cubit.dart';
import '../cubits/settings_state.dart';
import '../services/notification_service.dart';
import '../services/service_locator.dart';
import '../widgets/audio_player_bar.dart';

class AudioAzkarScreen extends StatelessWidget {
  const AudioAzkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.volume2, color: AppColors.primary, size: 22.r),
            SizedBox(width: 8.w),
            Text(
              'التسجيلات والأدعية الصوتية',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settingsState) {
            final motherName = settingsState.settings.motherName;
            final selectedAudioIdx = settingsState.settings.selectedAudioIndex;

            return BlocBuilder<DuaCubit, DuaState>(
              builder: (context, duaState) {
                if (duaState.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                final audioList = duaState.audioAzkar;

                if (audioList.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد تسجيلات صوتية متاحة حالياً',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    // Top Info Banner
                    Container(
                      margin: EdgeInsets.all(16.r),
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [AppColors.darkSurface, const Color(0xFF1F332A)]
                              : [AppColors.primary, AppColors.primaryDark],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 10.r,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              LucideIcons.mic,
                              color: Colors.white,
                              size: 24.r,
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'المقاطع والتسجيلات الصوتية (16 صوت)',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'يمكنك الاستماع لكل تسجيل أو تعيينه بنغمة الإشعارات',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Audio Player Bar if active
                    if (duaState.isPlayingAudio ||
                        duaState.audioDuration.inSeconds > 0)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: AudioPlayerBar(
                          position: duaState.audioPosition,
                          duration: duaState.audioDuration,
                          isPlaying: duaState.isPlayingAudio,
                          onTogglePlay: () {
                            if (duaState.currentAudioAzkar != null) {
                              context.read<DuaCubit>().playAudioAzkarItem(
                                    duaState.currentAudioAzkar!,
                                  );
                            } else {
                              context.read<DuaCubit>().toggleAudio();
                            }
                          },
                          onStop: () => context.read<DuaCubit>().stopAudio(),
                        ),
                      ),

                    SizedBox(height: 8.h),

                    // Audio Items List
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        itemCount: audioList.length,
                        itemBuilder: (context, index) {
                          final item = audioList[index];
                          final isCurrentPlaying =
                              duaState.currentAudioAzkar?.id == item.id &&
                                  duaState.isPlayingAudio;
                          final isSelectedForNotification =
                              selectedAudioIdx == item.id;

                          return Container(
                            margin: EdgeInsets.only(bottom: 12.h),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkSurface
                                  : AppColors.surface,
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
                                  color: Colors.black.withValues(
                                      alpha: isDark ? 0.2 : 0.03),
                                  blurRadius: 6.r,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 6.h,
                              ),
                              leading: GestureDetector(
                                onTap: () => context
                                    .read<DuaCubit>()
                                    .playAudioAzkarItem(item),
                                child: Container(
                                  width: 44.r,
                                  height: 44.r,
                                  decoration: BoxDecoration(
                                    color: isCurrentPlaying
                                        ? AppColors.primary
                                        : AppColors.primary
                                            .withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isCurrentPlaying
                                        ? LucideIcons.pause
                                        : LucideIcons.play,
                                    color: isCurrentPlaying
                                        ? Colors.white
                                        : AppColors.primary,
                                    size: 22.r,
                                  ),
                                ),
                              ),
                              title: Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                isSelectedForNotification
                                    ? 'محدد كنغمة إشعارات صوتية أساسية ✓'
                                    : 'اضغط للاستماع أو التجربة',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: isSelectedForNotification
                                      ? AppColors.primary
                                      : AppColors.textHint,
                                  fontWeight: isSelectedForNotification
                                      ? FontWeight.bold
                                      : FontWeight.normal,
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
                                      sl<NotificationService>()
                                          .showInstantAudioNotification(
                                        audioItem: item,
                                        motherName: motherName,
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'تم إرسال إشعار تجريبي بصوت: ${item.title}'),
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
                                        context
                                            .read<SettingsCubit>()
                                            .updateSelectedAudioIndex(item.id);
                                        final duaCubit =
                                            context.read<DuaCubit>();
                                        context
                                            .read<SettingsCubit>()
                                            .rescheduleNotifications(
                                              duas: duaCubit.state.duas,
                                              audioAzkar:
                                                  duaCubit.state.audioAzkar,
                                            );
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'select',
                                        child: Row(
                                          children: [
                                            Icon(LucideIcons.checkCircle,
                                                color: AppColors.primary),
                                            SizedBox(width: 8),
                                            Text(
                                                'تعيين كصوت الإشعارات المفضل'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
