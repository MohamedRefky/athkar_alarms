import 'package:azkar/models/settings_model.dart';
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
import '../widgets/audio_azkar/audio_azkar_banner.dart';
import '../widgets/audio_azkar/audio_azkar_filter_bar.dart';
import '../widgets/audio_azkar/audio_azkar_tile.dart';
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

                // Filter list
                List<AudioAzkarModel> displayList = allAudioList;
                if (_filter == 'female') {
                  displayList = allAudioList.where((a) => a.isFemale).toList();
                } else if (_filter == 'male') {
                  displayList = allAudioList.where((a) => a.isMale).toList();
                }

                return Column(
                  children: [
                    const AudioAzkarBanner(),

                    AudioAzkarFilterBar(
                      activeFilter: _filter,
                      onFilterChanged: (newFilter) {
                        setState(() => _filter = newFilter);
                      },
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

                          return AudioAzkarTile(
                            key: ValueKey(item.id),
                            item: item,
                            isCurrentPlaying: isCurrentPlaying,
                            isSelectedForNotification: isSelectedForNotification,
                            motherName: motherName,
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
