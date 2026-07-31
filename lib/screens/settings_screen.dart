import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app/app_colors.dart';
import '../cubits/dua_cubit.dart';
import '../cubits/settings_cubit.dart';
import '../cubits/settings_state.dart';
import '../widgets/settings/settings_audio_section.dart';
import '../widgets/settings/settings_dedication_footer_card.dart';
import '../widgets/settings/settings_header_card.dart';
import '../widgets/settings/settings_lock_permission_card.dart';
import '../widgets/settings/settings_mother_name_card.dart';
import '../widgets/settings/settings_splash_image_card.dart';
import '../widgets/settings/settings_text_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('إعدادات التطبيق والإشعارات'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: BlocConsumer<SettingsCubit, SettingsState>(
          listener: (context, state) {
            if (!state.isSaving) {
              final duaCubit = context.read<DuaCubit>();
              context.read<SettingsCubit>().rescheduleNotifications(
                    duas: duaCubit.state.duas,
                    audioAzkar: duaCubit.state.audioAzkar,
                  );
            }
          },
          builder: (context, state) {
            final settings = state.settings;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SettingsHeaderCard(),
                  SizedBox(height: 20.h),
                  const SettingsLockPermissionCard(),
                  SizedBox(height: 20.h),
                  SettingsMotherNameCard(initialName: settings.motherName),
                  SizedBox(height: 20.h),
                  SettingsSplashImageCard(
                    customSplashImagePath: settings.customSplashImagePath,
                  ),
                  SizedBox(height: 20.h),
                  SettingsAudioSection(settings: settings),
                  SizedBox(height: 20.h),
                  SettingsTextSection(settings: settings),
                  SizedBox(height: 24.h),
                  const SettingsDedicationFooterCard(),
                  SizedBox(height: 32.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
