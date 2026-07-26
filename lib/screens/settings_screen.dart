import 'package:azkar/cubits/dua_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../app/app_colors.dart';
import '../cubits/dua_cubit.dart';
import '../cubits/settings_cubit.dart';
import '../cubits/settings_state.dart';
import '../models/settings_model.dart';
import '../services/notification_service.dart';
import '../services/service_locator.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _customMinutesController;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsCubit>().state.settings;
    _nameController = TextEditingController(text: settings.motherName);
    _customMinutesController = TextEditingController(
      text: settings.customIntervalMinutes.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _customMinutesController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(BuildContext context, SettingsModel settings) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.dailyHour,
        minute: settings.dailyMinute,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      context.read<SettingsCubit>().updateDailyTime(picked.hour, picked.minute);
      final duaCubit = context.read<DuaCubit>();
      context
          .read<SettingsCubit>()
          .rescheduleNotifications(duaCubit.state.duas);
    }
  }

  Future<void> _pickCustomAudioFile(BuildContext context, int duaId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null && result.files.single.path != null && mounted) {
      final path = result.files.single.path!;
      context.read<SettingsCubit>().setCustomAudioForDua(duaId, path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم ربط التسجيل الصوتي بالدعاء بنجاح'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
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
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات التطبيق والإشعارات'),
      ),
      body: SafeArea(
        child: BlocConsumer<SettingsCubit, SettingsState>(
          listener: (context, state) {
            final duaCubit = context.read<DuaCubit>();
            context
                .read<SettingsCubit>()
                .rescheduleNotifications(duaCubit.state.duas);
          },
          builder: (context, state) {
            final settings = state.settings;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mother Name Section
                  _buildSectionHeader(
                    context,
                    title: 'اسم الوالدة المتوفاة',
                    icon: LucideIcons.user,
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.cardShadow,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'اكتب اسم والدتك ليتم إدراجه تلقائيًا في نص الأدعية والأذكار (مثلاً: "الحاجة صباح")',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'أدخل اسم الوالدة هنا...',
                            prefixIcon: const Icon(LucideIcons.heart,
                                color: AppColors.primary),
                            filled: true,
                            fillColor: isDark
                                ? AppColors.darkBackground
                                : AppColors.surfaceVariant,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (val) {
                            context.read<SettingsCubit>().updateMotherName(val);
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Notification Frequency Section
                  _buildSectionHeader(
                    context,
                    title: 'جدولة ومواعيد الإشعارات',
                    icon: LucideIcons.clock,
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.cardShadow,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        for (final freq in NotificationFrequency.values) ...[
                          RadioListTile<NotificationFrequency>(
                            value: freq,
                            groupValue: settings.frequency,
                            activeColor: AppColors.primary,
                            title: Text(
                              freq.label,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onChanged: (val) {
                              if (val != null) {
                                context
                                    .read<SettingsCubit>()
                                    .updateFrequency(val);
                              }
                            },
                          ),
                          if (freq == NotificationFrequency.onceDaily &&
                              settings.frequency ==
                                  NotificationFrequency.onceDaily) ...[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.w, vertical: 8.h),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'وقت الإشعار اليومي: ${settings.dailyHour.toString().padLeft(2, '0')}:${settings.dailyMinute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        _pickTime(context, settings),
                                    icon: const Icon(LucideIcons.calendar,
                                        size: 18),
                                    label: const Text('تغيير الوقت'),
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.w, vertical: 8.h),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (freq == NotificationFrequency.custom &&
                              settings.frequency ==
                                  NotificationFrequency.custom) ...[
                            Padding(
                              padding: EdgeInsets.all(16.r),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _customMinutesController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'التكرار بالدقائق',
                                        hintText: 'مثلاً: 45',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        final min = int.tryParse(val);
                                        if (min != null && min > 0) {
                                          context
                                              .read<SettingsCubit>()
                                              .updateCustomInterval(min);
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Text('دقيقة',
                                      style: TextStyle(fontSize: 16.sp)),
                                ],
                              ),
                            ),
                          ],
                          if (freq != NotificationFrequency.values.last)
                            const Divider(height: 1),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Notification Sound Toggle Section
                  _buildSectionHeader(
                    context,
                    title: 'إعدادات الصوت والتنبيهات',
                    icon: LucideIcons.volume2,
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.cardShadow,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: Column(
                      children: [
                        SwitchListTile(
                          value: settings.isAudioEnabled,
                          activeThumbColor: AppColors.primary,
                          title: Text(
                            'تفعيل الصوت المصاحب للإشعار',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'تشغيل الصوت المخصص عند تلقي الإشعار أو فتح التطبيق',
                            style: TextStyle(fontSize: 13.sp),
                          ),
                          onChanged: (val) {
                            context.read<SettingsCubit>().toggleAudio(val);
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(LucideIcons.bellRing,
                              color: AppColors.primary),
                          title: const Text('طلب أذونات الإشعارات الجهاز'),
                          subtitle: const Text(
                              'تأكد من تفعيل صلاحيات الإشعارات لضمان وصولها في موعدها'),
                          trailing: const Icon(LucideIcons.chevronLeft),
                          onTap: () => _requestNotificationPermissions(context),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Custom Audio Recording Assignment
                  _buildSectionHeader(
                    context,
                    title: 'ربط تسجيلات صوتية مخصصة بالأدعية',
                    icon: LucideIcons.mic,
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.cardShadow,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'يمكنك اختيار تسجيل بصوتك أو صوت أحد أفراد العائلة من جهازك وربطه بالأدعية:',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        BlocBuilder<DuaCubit, DuaState>(
                          builder: (context, duaState) {
                            if (duaState.duas.isEmpty) {
                              return const Text('جاري تحميل الأدعية...');
                            }
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: duaState.duas.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, index) {
                                final dua = duaState.duas[index];
                                final hasCustom =
                                    settings.customAudioMap.containsKey(dua.id);

                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    'دعاء #${dua.id}: ${dua.getFormattedText(settings.motherName)}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                  subtitle: Text(
                                    hasCustom
                                        ? 'صوت مخصص: ${settings.customAudioMap[dua.id]?.split('/').last}'
                                        : 'الصوت الافتراضي مسجل',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: hasCustom
                                          ? AppColors.success
                                          : AppColors.textHint,
                                      fontWeight: hasCustom
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (hasCustom)
                                        IconButton(
                                          icon: const Icon(LucideIcons.trash2,
                                              color: AppColors.error),
                                          onPressed: () {
                                            context
                                                .read<SettingsCubit>()
                                                .removeCustomAudioForDua(
                                                    dua.id);
                                          },
                                        ),
                                      IconButton(
                                        icon: Icon(
                                          hasCustom
                                              ? LucideIcons.fileCheck
                                              : LucideIcons.upload,
                                          color: AppColors.primary,
                                        ),
                                        onPressed: () => _pickCustomAudioFile(
                                            context, dua.id),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20.sp),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
