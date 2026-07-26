import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';

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
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSurface
                  : AppColors.surface,
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
        const SnackBar(
          content: Text('تم ربط التسجيل الصوتي بالدعاء بنجاح'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
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
          behavior: SnackBarBehavior.floating,
        ),
      );
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
            context
                .read<SettingsCubit>()
                .rescheduleNotifications(duaCubit.state.duas);
          },
          builder: (context, state) {
            final settings = state.settings;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Hero Info Banner
                  _buildHeaderCard(context, isDark),

                  SizedBox(height: 24.h),

                  // 1. Mother Name Section
                  _buildSectionHeader(
                    context,
                    title: 'اسم الوالدة المتوفاة',
                    subtitle: 'يتم تخصيص نص جميع الأدعية باسمها',
                    icon: LucideIcons.heart,
                  ),
                  SizedBox(height: 12.h),
                  _buildCardContainer(
                    isDark: isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.done,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'أدخل اسم الوالدة هنا...',
                            hintStyle: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textHint,
                            ),
                            prefixIcon: Icon(
                              LucideIcons.user,
                              color: AppColors.primary,
                              size: 20.r,
                            ),
                            suffixIcon: _nameController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: AppColors.textHint,
                                      size: 18.r,
                                    ),
                                    onPressed: () {
                                      _nameController.clear();
                                      context
                                          .read<SettingsCubit>()
                                          .updateMotherName('');
                                      setState(() {});
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: isDark
                                ? AppColors.darkBackground
                                : AppColors.surfaceVariant,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 14.h,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14.r),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14.r),
                              borderSide: BorderSide(
                                color: AppColors.primary.withValues(alpha: 0.5),
                                width: 1.5,
                              ),
                            ),
                          ),
                          onChanged: (val) {
                            context
                                .read<SettingsCubit>()
                                .updateMotherName(val);
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // 2. Notification Frequency Section
                  _buildSectionHeader(
                    context,
                    title: 'جدولة ومواعيد الإشعارات',
                    subtitle: 'تحديد معدل تكرار أذكار الوالدة',
                    icon: LucideIcons.clock,
                  ),
                  SizedBox(height: 12.h),
                  _buildCardContainer(
                    isDark: isDark,
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (int i = 0;
                            i < NotificationFrequency.values.length;
                            i++) ...[
                          _buildFrequencyTile(
                            context: context,
                            freq: NotificationFrequency.values[i],
                            currentFreq: settings.frequency,
                            settings: settings,
                            isDark: isDark,
                          ),
                          if (i < NotificationFrequency.values.length - 1)
                            Divider(
                              height: 1,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.05),
                            ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // 3. Audio & Permissions Section
                  _buildSectionHeader(
                    context,
                    title: 'الصوت والأذونات',
                    subtitle: 'التحكم في التلاوات الصوتية وإشعارات الهاتف',
                    icon: LucideIcons.volume2,
                  ),
                  SizedBox(height: 12.h),
                  _buildCardContainer(
                    isDark: isDark,
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        SwitchListTile(
                          value: settings.isAudioEnabled,
                          activeThumbColor: Colors.white,
                          activeTrackColor: AppColors.primary,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 4.h,
                          ),
                          title: Text(
                            'تفعيل التلاوة الصوتية',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            'تشغيل تلاوة الدعاء عند فتح التنبيهات أو التطبيق',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          onChanged: (val) {
                            context.read<SettingsCubit>().toggleAudio(val);
                          },
                        ),
                        Divider(
                          height: 1,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.05),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 4.h,
                          ),
                          leading: Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              LucideIcons.bellRing,
                              color: AppColors.primary,
                              size: 20.r,
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
                            'التأكد من السماح بإرسال التنبيهات في الخلفية',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          trailing: Icon(
                            LucideIcons.chevronLeft,
                            size: 18.r,
                            color: AppColors.textHint,
                          ),
                          onTap: () =>
                              _requestNotificationPermissions(context),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // 4. Custom Audio Section
                  _buildSectionHeader(
                    context,
                    title: 'التسجيلات الصوتية الخاصة',
                    subtitle: 'إمكانية رفع صوت مخصص لكل دعاء بصوتك',
                    icon: LucideIcons.mic,
                  ),
                  SizedBox(height: 12.h),
                  _buildCardContainer(
                    isDark: isDark,
                    child: BlocBuilder<DuaCubit, DuaState>(
                      builder: (context, duaState) {
                        if (duaState.duas.isEmpty) {
                          return Padding(
                            padding: EdgeInsets.all(12.r),
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primary),
                            ),
                          );
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: duaState.duas.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 16.h,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.05),
                          ),
                          itemBuilder: (context, index) {
                            final dua = duaState.duas[index];
                            final hasCustom = settings.customAudioMap
                                .containsKey(dua.id);

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                'دعاء #${dua.id}: ${dua.getFormattedText(settings.motherName)}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Padding(
                                padding: EdgeInsets.only(top: 4.h),
                                child: Text(
                                  hasCustom
                                      ? 'صوت مخصص: ${settings.customAudioMap[dua.id]?.split('/').last}'
                                      : 'الصوت الافتراضي مفعل',
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
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (hasCustom)
                                    IconButton(
                                      icon: Icon(
                                        LucideIcons.trash2,
                                        color: AppColors.error,
                                        size: 18.r,
                                      ),
                                      onPressed: () {
                                        context
                                            .read<SettingsCubit>()
                                            .removeCustomAudioForDua(dua.id);
                                      },
                                    ),
                                  IconButton(
                                    icon: Icon(
                                      hasCustom
                                          ? LucideIcons.fileCheck
                                          : LucideIcons.upload,
                                      color: AppColors.primary,
                                      size: 20.r,
                                    ),
                                    onPressed: () =>
                                        _pickCustomAudioFile(context, dua.id),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // 5. Dedication Card & Re-open Onboarding
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
              ? [AppColors.darkSurface, Color(0xFF1B2E26)]
              : [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16.r,
            offset: const Offset(0, 6),
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
              LucideIcons.settings,
              color: AppColors.accentGold,
              size: 28.r,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إعدادات التذكير والإهداء',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'خصص مواعيد الأذكار واسم المرحومة والتسجيلات',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: AppColors.primary, size: 18.r),
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Padding(
          padding: EdgeInsets.only(right: 32.w),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textHint,
            ),
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
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : AppColors.primary.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: padding ?? EdgeInsets.all(16.r),
          child: child,
        ),
      ),
    );
  }

  Widget _buildFrequencyTile({
    required BuildContext context,
    required NotificationFrequency freq,
    required NotificationFrequency currentFreq,
    required SettingsModel settings,
    required bool isDark,
  }) {
    final isSelected = freq == currentFreq;

    return Column(
      children: [
        RadioListTile<NotificationFrequency>(
          value: freq,
          groupValue: currentFreq,
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
          title: Text(
            freq.label,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? AppColors.primary
                  : (isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary),
            ),
          ),
          onChanged: (val) {
            if (val != null) {
              context.read<SettingsCubit>().updateFrequency(val);
            }
          },
        ),
        if (freq == NotificationFrequency.onceDaily && isSelected) ...[
          Container(
            margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.clock,
                        size: 18.r, color: AppColors.primary),
                    SizedBox(width: 8.w),
                    Text(
                      'الموعد اليومي: ${settings.dailyHour.toString().padLeft(2, '0')}:${settings.dailyMinute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickTime(context, settings),
                  icon: Icon(LucideIcons.calendar, size: 16.r),
                  label: const Text('تغيير الوقت'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    textStyle: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (freq == NotificationFrequency.custom && isSelected) ...[
          Container(
            margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _customMinutesController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      labelText: 'التكرار بالدقائق',
                      hintText: 'مثلاً: 45',
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkBackground
                          : AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 10.h),
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
                Text(
                  'دقيقة',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDedicationFooterCard(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.accentGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.heart,
                  size: 18.r, color: AppColors.accentGold),
              SizedBox(width: 8.w),
              Text(
                'صدقة جارية',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentGold,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            'عن المرحومة صباح عجمي أحمد محمد ريان',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.primaryDark,
            ),
          ),
          SizedBox(height: 12.h),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const OnboardingScreen(),
                ),
              );
            },
            icon: Icon(LucideIcons.bookOpen,
                size: 16.r, color: AppColors.primary),
            label: const Text('عرض سورة الفاتحة والإهداء'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
