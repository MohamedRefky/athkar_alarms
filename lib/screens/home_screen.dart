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
import 'onboarding_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
            Icon(LucideIcons.heart, color: AppColors.primary, size: 22.r),
            SizedBox(width: 8.w),
            Text(
              'اللهم ارحم أمي',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'عرض الفاتحة والإهداء',
            icon: Icon(
              LucideIcons.bookOpen,
              color: AppColors.primary,
              size: 22.r,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const OnboardingScreen(),
                ),
              );
            },
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settingsState) {
            final motherName = settingsState.settings.motherName;

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
                          Icon(
                            LucideIcons.alertCircle,
                            size: 48.r,
                            color: AppColors.error,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            duaState.errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: AppColors.error,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          CustomButton(
                            text: 'إعادة المحاولة',
                            onPressed: () =>
                                context.read<DuaCubit>().loadDuas(),
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
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Subheader Header Banner (Mother Name Dedication at top only)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 18.w, vertical: 14.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [AppColors.darkSurface, const Color(0xFF1F332A)]
                                : [AppColors.surfaceVariant, Colors.white],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          borderRadius: BorderRadius.circular(18.r),
                          border: Border.all(
                            color: AppColors.accentGold.withValues(alpha: 0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: isDark ? 0.2 : 0.04),
                              blurRadius: 10.r,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: AppColors.accentGold
                                    .withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                LucideIcons.sparkles,
                                color: AppColors.accentGold,
                                size: 20.r,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                motherName.trim().isNotEmpty
                                    ? 'دعاء وصلاة لروح المرحومة: $motherName'
                                    : 'تذكير بالدعاء الصالح للأم المتوفاة',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Dua Main Display Card (With 'آمين' button directly under the text)
                      DuaCard(
                        formattedText: formattedText,
                        motherName: motherName,
                        onNextDua: () {
                          context.read<DuaCubit>().nextRandomDua();
                        },
                      ),

                      SizedBox(height: 20.h),

                      // Main Action Button (Random Dua Shuffle)
                      CustomButton(
                        text: 'دعاء عشوائي جديد فورًا 🤲',
                        icon: LucideIcons.shuffle,
                        onPressed: () {
                          context.read<DuaCubit>().nextRandomDua();
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