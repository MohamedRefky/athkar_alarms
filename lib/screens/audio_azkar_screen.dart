import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../app/app_colors.dart';
import '../cubits/dua_cubit.dart';
import '../cubits/dua_state.dart';
import '../cubits/settings_cubit.dart';
import '../cubits/settings_state.dart';
import '../models/audio_azkar_model.dart';
import '../models/settings_model.dart';
import '../services/notification_service.dart';
import '../services/service_locator.dart';
import '../widgets/audio_player_bar.dart';

class AudioAzkarScreen extends StatefulWidget {
  const AudioAzkarScreen({super.key});

  @override
  State<AudioAzkarScreen> createState() => _AudioAzkarScreenState();
}

class _AudioAzkarScreenState extends State<AudioAzkarScreen> {
  String _filter = 'all'; // 'all', 'female', 'male'

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
            final currentTarget = settingsState.settings.audioGenderTarget;

            return BlocBuilder<DuaCubit, DuaState>(
              builder: (context, duaState) {
                if (duaState.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                final allAudioList = duaState.audioAzkar;

                if (allAudioList.isEmpty) {
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

                final femaleCount =
                    allAudioList.where((a) => a.isFemale).length;
                final maleCount = allAudioList.where((a) => a.isMale).length;

                // Filter list
                List<AudioAzkarModel> displayList = allAudioList;
                if (_filter == 'female') {
                  displayList = allAudioList.where((a) => a.isFemale).toList();
                } else if (_filter == 'male') {
                  displayList = allAudioList.where((a) => a.isMale).toList();
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
                        borderRadius: BorderRadius.circular(20.r),
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
                            padding: EdgeInsets.all(12.r),
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
                                  'مكتبة الأدعية والتسجيلات الصوتية (15 صوتاً)',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'تم توزيع الأدعية بين خيارات المرحومة وخيارات المرحوم لتخصيص التذكير بنية الدعاء.',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Filter Tabs Header
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Row(
                          children: [
                            _buildFilterTab(
                              id: 'all',
                              title: 'كافة الأصوات',
                              icon: LucideIcons.layers,
                              isSelected: _filter == 'all',
                              isDark: isDark,
                            ),
                            _buildFilterTab(
                              id: 'female',
                              title: 'أدعية المرحومة',
                              icon: LucideIcons.heart,
                              isSelected: _filter == 'female',
                              isDark: isDark,
                            ),
                            _buildFilterTab(
                              id: 'male',
                              title: 'أدعية المرحوم',
                              icon: LucideIcons.userCheck,
                              isSelected: _filter == 'male',
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 10.h),

                    // Active Target Indicator
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        children: [
                          Icon(LucideIcons.bell,
                              size: 14.r, color: AppColors.accentGold),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              'مصدر إشعارات الصوت المعتمد حالياً: ${currentTarget.label}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 10.h),

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

                    SizedBox(height: 4.h),

                    // Audio Items List
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        itemCount: displayList.length,
                        itemBuilder: (context, index) {
                          final item = displayList[index];
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
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(16.r),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
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
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        style: TextStyle(
                                          fontSize: 14.5.sp,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? AppColors.darkTextPrimary
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.w, vertical: 3.h),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                        border: Border.all(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.25),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            item.isFemale
                                                ? LucideIcons.heart
                                                : LucideIcons.userCheck,
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
                                      color: isSelectedForNotification
                                          ? AppColors.primary
                                          : AppColors.textHint,
                                      fontWeight: isSelectedForNotification
                                          ? FontWeight.bold
                                          : FontWeight.normal,
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

  Widget _buildFilterTab({
    required String id,
    required String title,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    Color activeColor = AppColors.primary,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filter = id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
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
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary),
              ),
              SizedBox(width: 6.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
