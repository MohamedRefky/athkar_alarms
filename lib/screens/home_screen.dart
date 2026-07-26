import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../app/app_colors.dart';
import '../cubits/dua_cubit.dart';
import '../cubits/dua_state.dart';
import '../cubits/settings_cubit.dart';
import '../cubits/settings_state.dart';
import '../widgets/dua_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/audio_player_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.heart, color: AppColors.primary, size: 22.sp),
            SizedBox(width: 8.w),
            const Text('اللهم ارحم أمي'),
          ],
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settingsState) {
            final motherName = settingsState.settings.motherName;
            final customAudioMap = settingsState.settings.customAudioMap;

            return BlocBuilder<DuaCubit, DuaState>(
              builder: (context, duaState) {
                if (duaState.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (duaState.errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.alertCircle, size: 48.sp, color: AppColors.error),
                          SizedBox(height: 16.h),
                          Text(
                            duaState.errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18.sp, color: AppColors.error),
                          ),
                          SizedBox(height: 16.h),
                          CustomButton(
                            text: 'إعادة المحاولة',
                            onPressed: () => context.read<DuaCubit>().loadDuas(),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final currentDua = duaState.currentDua;
                if (currentDua == null) {
                  return const Center(child: Text('لا توجد أدعية متاحة'));
                }

                final formattedText = currentDua.getFormattedText(motherName);

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Subheader Header Notice
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.sparkles,
                              color: AppColors.accentGold,
                              size: 22.sp,
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                motherName.trim().isNotEmpty
                                    ? 'دعاء وصلاة على روح المرحومة: $motherName'
                                    : 'تذكير بالدعاء الصالح والأذكار للأم المتوفاة',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Dua Main Display Card
                      DuaCard(
                        formattedText: formattedText,
                        motherName: motherName,
                        isPlayingAudio: duaState.isPlayingAudio,
                        onToggleAudio: () {
                          context.read<DuaCubit>().toggleAudio(
                                customAudioMap: customAudioMap,
                              );
                        },
                        onNextDua: () {
                          context.read<DuaCubit>().nextRandomDua();
                        },
                      ),

                      SizedBox(height: 20.h),

                      // Audio Player Bar if active or duration loaded
                      if (duaState.isPlayingAudio || duaState.audioDuration > Duration.zero) ...[
                        AudioPlayerBar(
                          isPlaying: duaState.isPlayingAudio,
                          position: duaState.audioPosition,
                          duration: duaState.audioDuration,
                          onTogglePlay: () {
                            context.read<DuaCubit>().toggleAudio(
                                  customAudioMap: customAudioMap,
                                );
                          },
                          onStop: () {
                            context.read<DuaCubit>().stopAudio();
                          },
                        ),
                        SizedBox(height: 20.h),
                      ],

                      // Main Action Buttons
                      CustomButton(
                        text: 'دعاء عشوائي جديد فورًا 🤲',
                        icon: LucideIcons.shuffle,
                        onPressed: () {
                          context.read<DuaCubit>().nextRandomDua();
                        },
                      ),

                      SizedBox(height: 12.h),

                      CustomButton(
                        text: duaState.isPlayingAudio
                            ? 'إيقاف التلاوة والصوت ⏹️'
                            : 'تشغيل الصوت المصاحب للدعاء 🔊',
                        icon: duaState.isPlayingAudio ? LucideIcons.square : LucideIcons.volume2,
                        isSecondary: true,
                        onPressed: () {
                          context.read<DuaCubit>().toggleAudio(
                                customAudioMap: customAudioMap,
                              );
                        },
                      ),

                      SizedBox(height: 24.h),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
