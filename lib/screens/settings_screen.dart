import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../app/app_colors.dart';
import '../cubits/dua_cubit.dart';
import '../cubits/dua_state.dart';
import '../cubits/settings_cubit.dart';
import '../cubits/settings_state.dart';
import '../models/settings_model.dart';
import '../services/notification_service.dart';
import '../services/service_locator.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsCubit>().state.settings;
    _nameController = TextEditingController(text: settings.motherName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _requestNotificationPermissions(BuildContext context) async {
    final notificationService = sl<NotificationService>();
    final granted = await notificationService.requestPermissions();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            granted
                ? 'تم منح إذن الإشعارات بنجاح'
                : 'لم يتم منح إذن الإشعارات، يرجى التفعيل من إعدادات الهاتف',
          ),
          backgroundColor: granted ? AppColors.primary : AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showCustomIntervalDialog(
    BuildContext context,
    bool isAudio,
    int initialValue,
  ) async {
    final controller = TextEditingController(text: initialValue.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isAudio
              ? 'تحديد مدة تكرار الصوت بالدقائق'
              : 'تحديد مدة تكرار النص بالدقائق',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'أدخل عدد الدقائق (مثلاً: 45)',
            suffixText: 'دقيقة',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              Navigator.pop(context, val);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (result != null && result > 0 && mounted) {
      if (isAudio) {
        context.read<SettingsCubit>().updateAudioCustomInterval(result);
        context.read<SettingsCubit>().updateAudioFrequency(NotificationFrequency.custom);
      } else {
        context.read<SettingsCubit>().updateTextCustomInterval(result);
        context.read<SettingsCubit>().updateTextFrequency(NotificationFrequency.custom);
      }
    }
  }

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
            final duaCubit = context.read<DuaCubit>();
            context.read<SettingsCubit>().rescheduleNotifications(
                  duas: duaCubit.state.duas,
                  audioAzkar: duaCubit.state.audioAzkar,
                );
          },
          builder: (context, state) {
            final settings = state.settings;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  _buildHeaderCard(context, isDark),

                  SizedBox(height: 24.h),

                  // 1. Mother Name Section
                  _buildSectionHeader(
                    context,
                    title: 'اسم الوالدة المتوفاة',
                    subtitle: 'تخصيص نص ونية الدعاء باسمها',
                    icon: LucideIcons.heart,
                  ),
                  SizedBox(height: 12.h),
                  _buildCardContainer(
                    isDark: isDark,
                    child: TextFormField(
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'أدخل اسم الوالدة هنا...',
                        prefixIcon: Icon(
                          LucideIcons.user,
                          color: AppColors.primary,
                          size: 20.r,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.darkBackground
                            : AppColors.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        context.read<SettingsCubit>().updateMotherName(val);
                      },
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // 2. Audio Notifications Section (Recorded Audio Clips)
                  _buildSectionHeader(
                    context,
                    title: '1. الإشعارات وتكرار أصوات الأدعية 🎧',
                    subtitle: 'تكرار أصوات المقاطع الـ 16 بتتابع زمني محدد',
                    icon: LucideIcons.volume2,
                  ),
                  SizedBox(height: 12.h),
                  _buildCardContainer(
                    isDark: isDark,
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        SwitchListTile(
                          value: settings.isAudioNotificationsEnabled,
                          activeTrackColor: AppColors.primary,
                          activeColor: Colors.white,
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
                          trackOutlineColor:
                              WidgetStateProperty.all(Colors.transparent),
                          title: Text(
                            'تفعيل نظام الإشعارات الصوتية',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            'إرسال إشعار ينطق بصوت المقطع التالي في كل مرة',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textHint,
                            ),
                          ),
                          onChanged: (val) {
                            context
                                .read<SettingsCubit>()
                                .toggleAudioNotifications(val);
                          },
                        ),
                        if (settings.isAudioNotificationsEnabled) ...[
                          Divider(
                            height: 1,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.05),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.r),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'معدل تكرار إشعارات الصوت (الفارق الزمني):',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Wrap(
                                  spacing: 8.w,
                                  runSpacing: 8.h,
                                  children: NotificationFrequency.values
                                      .map((freq) {
                                    final isSelected =
                                        settings.audioFrequency == freq;
                                    return ChoiceChip(
                                      label: Text(freq.label),
                                      selected: isSelected,
                                      selectedColor: AppColors.primary,
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : (isDark
                                                ? AppColors.darkTextPrimary
                                                : AppColors.textPrimary),
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                      onSelected: (selected) {
                                        if (selected) {
                                          if (freq == NotificationFrequency.custom) {
                                            _showCustomIntervalDialog(
                                              context,
                                              true,
                                              settings.audioCustomIntervalMinutes,
                                            );
                                          } else {
                                            context
                                                .read<SettingsCubit>()
                                                .updateAudioFrequency(freq);
                                          }
                                        }
                                      },
                                    );
                                  }).toList(),
                                ),
                                SizedBox(height: 12.h),
                                Divider(
                                  height: 1,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.black.withValues(alpha: 0.05),
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  'نمط اختيار الصوت:',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                RadioListTile<int>(
                                  value: 0,
                                  groupValue: settings.selectedAudioIndex,
                                  title: const Text('تتابع متسلسل بين الـ 16 صوت (صوت جديد كل فترة) 🔁'),
                                  subtitle: const Text('الساعة الأولى صوت 1، الساعة الثانية صوت 2... وهكذا'),
                                  onChanged: (val) {
                                    if (val != null) {
                                      context.read<SettingsCubit>().updateSelectedAudioIndex(val);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // 3. Text Notifications Section (Written Duas)
                  _buildSectionHeader(
                    context,
                    title: '2. إشعارات الأدعية المكتوبة 📖',
                    subtitle: 'التذكيرات النصية المكتوبة للأدعية الـ 30',
                    icon: LucideIcons.bookOpenText,
                  ),
                  SizedBox(height: 12.h),
                  _buildCardContainer(
                    isDark: isDark,
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        SwitchListTile(
                          value: settings.isTextNotificationsEnabled,
                          activeTrackColor: AppColors.primary,
                          activeColor: Colors.white,
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
                          trackOutlineColor:
                              WidgetStateProperty.all(Colors.transparent),
                          title: Text(
                            'تفعيل إشعارات الأدعية المكتوبة',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            'إرسال تنبيهات نصية دورية للأدعية المكتوبة',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textHint,
                            ),
                          ),
                          onChanged: (val) {
                            context
                                .read<SettingsCubit>()
                                .toggleTextNotifications(val);
                          },
                        ),
                        if (settings.isTextNotificationsEnabled) ...[
                          Divider(
                            height: 1,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.05),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.r),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'تكرار الإشعارات النصية:',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Wrap(
                                  spacing: 8.w,
                                  runSpacing: 8.h,
                                  children: NotificationFrequency.values
                                      .map((freq) {
                                    final isSelected =
                                        settings.textFrequency == freq;
                                    return ChoiceChip(
                                      label: Text(freq.label),
                                      selected: isSelected,
                                      selectedColor: AppColors.primary,
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : (isDark
                                                ? AppColors.darkTextPrimary
                                                : AppColors.textPrimary),
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                      onSelected: (selected) {
                                        if (selected) {
                                          if (freq == NotificationFrequency.custom) {
                                            _showCustomIntervalDialog(
                                              context,
                                              false,
                                              settings.textCustomIntervalMinutes,
                                            );
                                          } else {
                                            context
                                                .read<SettingsCubit>()
                                                .updateTextFrequency(freq);
                                          }
                                        }
                                      },
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // 4. Permissions Button Card
                  _buildCardContainer(
                    isDark: isDark,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          LucideIcons.bellRing,
                          color: AppColors.primary,
                          size: 22.r,
                        ),
                      ),
                      title: Text(
                        'إذن إشعارات النظام',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'منح الإذن ليعمل النظام وإشعارات الصوت بالشكل المطلوب',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textHint,
                        ),
                      ),
                      trailing: Icon(
                        LucideIcons.chevronLeft,
                        size: 20.r,
                        color: AppColors.textHint,
                      ),
                      onTap: () => _requestNotificationPermissions(context),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // 5. Dedication Footer
                  _buildDedicationFooterCard(context, isDark),

                  SizedBox(height: 32.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkSurface, const Color(0xFF1B2E26)]
              : [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 12.r,
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
              LucideIcons.slidersHorizontal,
              color: Colors.white,
              size: 28.r,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تحكم وتكرار الإشعارات',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'تكرار التسجيلات الصوتية بتتابع زمني مرن',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20.r),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textHint,
          ),
        ),
      ],
    );
  }

  Widget _buildCardContainer({
    required bool isDark,
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8.r,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: padding ?? EdgeInsets.all(16.r),
          child: child,
        ),
      ),
    );
  }

  Widget _buildDedicationFooterCard(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.heart, color: AppColors.accentGold, size: 24.r),
          SizedBox(height: 8.h),
          Text(
            'اللهم اغفر لأمنا وارحمها، واجعل هذا العمل صدقة جارية لها.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          OutlinedButton.icon(
            icon: Icon(LucideIcons.bookOpen, size: 16.r),
            label: const Text('قراءة سورة الفاتحة والإهداء'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const OnboardingScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
