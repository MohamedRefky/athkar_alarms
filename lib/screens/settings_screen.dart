import 'dart:io';

import 'package:azkar/models/settings_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';

import '../app/app_colors.dart';
import '../cubits/dua_cubit.dart';
import '../cubits/settings_cubit.dart';
import '../cubits/settings_state.dart';
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
  bool _isPickingImage = false;

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
    final granted = await notificationService.setupEverything();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            granted
                ? 'تم تفعيل جميع أذونات الإشعارات بنجاح ⚡'
                : 'يرجى منح الأذونات المطلوبة لضمان عمل الإشعارات',
          ),
          backgroundColor: granted ? AppColors.primary : AppColors.accentGold,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showLockScreenPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.bellRing, color: AppColors.primary, size: 22.r),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'ضمان عمل الإشعارات عند قفل الشاشة 🔔',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'لضمان وصول صوت الأذكار في موعدها وقبل قفل الشاشة بدون أي تأخير:',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 14.h),
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.sparkles, color: AppColors.primary, size: 22.r),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'اضغط على زر التفعيل أدناه لمنح كافّة الأذونات المطلوبة تلقائياً بضغطة واحدة.',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 48.h,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      elevation: 3,
                    ),
                    icon: Icon(LucideIcons.zap, size: 18.r),
                    label: Text(
                      'تفعيل كافّة الأذونات',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(dialogContext);
                      final notificationService = sl<NotificationService>();
                      final ok = await notificationService.setupEverything();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? 'تم تفعيل جميع أذونات الإشعارات بنجاح ⚡'
                                  : 'تم طلب الأذونات، يرجى تفعيل الأذونات عند ظهور رسائل النظام',
                            ),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                ),
                SizedBox(height: 8.h),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    side: BorderSide(
                      color: (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)
                          .withValues(alpha: 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                  icon: Icon(LucideIcons.settings, size: 16.r),
                  label: Text(
                    'إعدادات الهاتف ',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    await openAppSettings();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogStepRow(String iconStr, String text, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(iconStr, style: TextStyle(fontSize: 14.sp)),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.5.sp,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showCustomIntervalSheet(
    BuildContext context,
    bool isAudio,
    int currentIntervalMins,
  ) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = TextEditingController(
      text: currentIntervalMins > 0 ? '$currentIntervalMins' : '60',
    );

    void addMinutes(int mins) {
      final current = int.tryParse(controller.text) ?? 0;
      controller.text = '${(current + mins).clamp(1, 1440)}';
    }

    final result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24.w,
                right: 24.w,
                top: 20.h,
                bottom: MediaQuery.of(context).viewInsets.bottom + 28.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: AppColors.textHint.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          LucideIcons.timer,
                          color: AppColors.primary,
                          size: 24.r,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          isAudio
                              ? 'تحديد الوقت الفاصل لإشعارات الصوت'
                              : 'تحديد الوقت الفاصل لإشعارات النص',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'إضافة سريعة للوقت:',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHint,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPresetChip(
                          '+15د', () => setSheetState(() => addMinutes(15))),
                      _buildPresetChip(
                          '+30د', () => setSheetState(() => addMinutes(30))),
                      _buildPresetChip(
                          '+1س', () => setSheetState(() => addMinutes(60))),
                      _buildPresetChip(
                          '+2س', () => setSheetState(() => addMinutes(120))),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkBackground
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      decoration: InputDecoration(
                        suffixText: 'دقيقة',
                        suffixStyle: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textHint,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 54.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 4,
                        shadowColor: AppColors.primary.withValues(alpha: 0.4),
                      ),
                      onPressed: () {
                        final val = int.tryParse(controller.text);
                        Navigator.pop(context, val);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.checkCircle2,
                              color: Colors.white, size: 20.r),
                          SizedBox(width: 8.w),
                          Text(
                            'تأكيد وحفظ الوقت ⚡',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result != null && result > 0 && mounted) {
      if (isAudio) {
        context.read<SettingsCubit>().updateAudioCustomInterval(result);
      } else {
        context.read<SettingsCubit>().updateTextCustomInterval(result);
      }
    }
  }

  Widget _buildPresetChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.25),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
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
                  _buildHeaderCard(context, isDark),
                  SizedBox(height: 24.h),
                  _buildSectionHeader(
                    context,
                    title: 'اسم الوالدة المتوفاة 🤍',
                    subtitle:
                        'تخصيص نص ونية الدعاء باسمها في كافة الشاشات والإشعارات',
                    icon: LucideIcons.heart,
                  ),
                  SizedBox(height: 12.h),
                  _buildCardContainer(
                    isDark: isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
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
                        ),
                        SizedBox(height: 12.h),
                        SizedBox(
                          height: 44.h,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            icon: Icon(LucideIcons.save,
                                color: Colors.white, size: 18.r),
                            label: Text(
                              'حفظ وتحديث الاسم 💾',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () {
                              final name = _nameController.text.trim();
                              context
                                  .read<SettingsCubit>()
                                  .updateMotherName(name);
                              FocusScope.of(context).unfocus();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(LucideIcons.checkCircle2,
                                          color: Colors.white, size: 20.r),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Text(
                                          name.isNotEmpty
                                              ? 'تم حفظ وتحديث اسم الوالدة بنجاح: "$name" 🤍'
                                              : 'تم تحديث الاسم بنجاح 🤍',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: AppColors.primary,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _buildSectionHeader(
                    context,
                    title: 'صورة شاشة البداية (Splash Screen) 🖼️',
                    subtitle:
                        'تغيير وتخصيص الصورة المعروضة عند فتح التطبيق من المعرض',
                    icon: LucideIcons.image,
                  ),
                  SizedBox(height: 12.h),
                  _buildCardContainer(
                    isDark: isDark,
                    child: Column(
                      children: [
                        Container(
                          height: 220.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkBackground
                                : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              width: 1.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18.5.r),
                            child: Builder(
                              builder: (context) {
                                final hasCustomFile =
                                    settings.customSplashImagePath != null &&
                                        settings.customSplashImagePath!
                                            .isNotEmpty &&
                                        File(settings.customSplashImagePath!)
                                            .existsSync();

                                return Stack(
                                  children: [
                                    // Main Image filling 100% of the card with zero black spaces
                                    Positioned.fill(
                                      child: hasCustomFile
                                          ? Image.file(
                                              File(settings
                                                  .customSplashImagePath!),
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                              filterQuality: FilterQuality.high,
                                            )
                                          : Container(
                                              width: double.infinity,
                                              height: double.infinity,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: isDark
                                                      ? [
                                                          const Color(0xFF1B382B),
                                                          AppColors.darkSurface
                                                        ]
                                                      : [
                                                          AppColors.surfaceVariant,
                                                          Colors.white
                                                        ],
                                                  begin: Alignment.topRight,
                                                  end: Alignment.bottomLeft,
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    padding:
                                                        EdgeInsets.all(16.r),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: AppColors.primary
                                                          .withValues(
                                                              alpha: 0.12),
                                                      border: Border.all(
                                                        color: AppColors.accentGold
                                                            .withValues(
                                                                alpha: 0.4),
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                    child: Icon(
                                                      Icons.volunteer_activism,
                                                      size: 48.r,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                  SizedBox(height: 8.h),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        LucideIcons.sparkles,
                                                        size: 14.r,
                                                        color: AppColors
                                                            .accentGold,
                                                      ),
                                                      SizedBox(width: 4.w),
                                                      Text(
                                                        'أيقونة الصدقة الجارية الافتراضية',
                                                        style: TextStyle(
                                                          fontSize: 13.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              AppColors.primary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ),
                                    // Status Badge Overlay
                                    Positioned(
                                      top: 10.h,
                                      right: 10.w,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.w, vertical: 5.h),
                                        decoration: BoxDecoration(
                                          color: (hasCustomFile
                                                  ? AppColors.primary
                                                  : AppColors.accentGold)
                                              .withValues(alpha: 0.9),
                                          borderRadius:
                                              BorderRadius.circular(20.r),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.2),
                                              blurRadius: 6.r,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              hasCustomFile
                                                  ? LucideIcons.checkCircle2
                                                  : LucideIcons.image,
                                              size: 13.r,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 5.w),
                                            Text(
                                              hasCustomFile
                                                  ? 'صورة مخصصة ✨'
                                                  : 'الأيقونة الافتراضية 🕊️',
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 14.h),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(
                                      color: AppColors.primary),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                ),
                                icon: Icon(LucideIcons.upload, size: 18.r),
                                label: Text(
                                  'اختيار صورة من المعرض 🖼️',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: _isPickingImage
                                    ? null
                                    : () async {
                                        setState(() => _isPickingImage = true);
                                        try {
                                          final result = await FilePicker
                                              .platform
                                              .pickFiles(
                                            type: FileType.image,
                                            allowMultiple: false,
                                          );
                                          if (result != null &&
                                              result.files.single.path !=
                                                  null &&
                                              mounted) {
                                            final imagePath =
                                                result.files.single.path!;

                                            // Copy picked image to persistent directory
                                            String savedPath = imagePath;
                                            try {
                                              final pickedFile =
                                                  File(imagePath);
                                              final persistentDir = Directory(
                                                  '${pickedFile.parent.parent.path}/persistent_splash');
                                              if (!persistentDir.existsSync()) {
                                                await persistentDir.create(
                                                    recursive: true);
                                              }
                                              final extension = pickedFile.path
                                                  .split('.')
                                                  .last;
                                              final targetFile = File(
                                                  '${persistentDir.path}/splash_image.$extension');
                                              await pickedFile
                                                  .copy(targetFile.path);
                                              savedPath = targetFile.path;
                                            } catch (_) {}

                                            if (mounted) {
                                              context
                                                  .read<SettingsCubit>()
                                                  .updateCustomSplashImagePath(
                                                      savedPath);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Row(
                                                    children: [
                                                      Icon(
                                                          LucideIcons
                                                              .checkCircle2,
                                                          color: Colors.white,
                                                          size: 20.r),
                                                      SizedBox(width: 10.w),
                                                      const Expanded(
                                                        child: Text(
                                                          'تم تحديث صورة شاشة البداية بنجاح 🖼️',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  backgroundColor:
                                                      AppColors.primary,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.r),
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        } catch (e) {
                                          debugPrint('File picker error: $e');
                                        } finally {
                                          if (mounted) {
                                            setState(
                                                () => _isPickingImage = false);
                                          }
                                        }
                                      },
                              ),
                            ),
                            if (settings.customSplashImagePath != null) ...[
                              SizedBox(width: 10.w),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side:
                                      const BorderSide(color: AppColors.error),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12.h, horizontal: 12.w),
                                ),
                                icon: Icon(LucideIcons.rotateCcw, size: 18.r),
                                label: Text(
                                  'الافتراضية',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () {
                                  context
                                      .read<SettingsCubit>()
                                      .updateCustomSplashImagePath(null);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(LucideIcons.checkCircle2,
                                              color: Colors.white, size: 20.r),
                                          SizedBox(width: 10.w),
                                          const Expanded(
                                            child: Text(
                                              'تمت استعادة الصورة الافتراضية 🔄',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: AppColors.primary,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _buildSectionHeader(
                    context,
                    title: '1. الإشعارات وتكرار أصوات الأدعية 🎧',
                    subtitle: 'تكرار أصوات المقاطع الـ 16 بتتابع زمني مخصص',
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
                          activeThumbColor: Colors.white,
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
                          onChanged: (val) async {
                            if (val) {
                              await _requestNotificationPermissions(context);
                            }
                            if (context.mounted) {
                              context
                                  .read<SettingsCubit>()
                                  .toggleAudioNotifications(val);
                            }
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
                            padding: EdgeInsets.all(16.r),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Single Custom Time Selector Card
                                _buildSingleCustomTimeCard(
                                  context: context,
                                  isAudio: true,
                                  intervalMins: settings
                                      .getEffectiveAudioIntervalMinutes(),
                                  isDark: isDark,
                                ),

                                SizedBox(height: 16.h),
                                Divider(
                                  height: 1,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.black.withValues(alpha: 0.05),
                                ),
                                SizedBox(height: 12.h),
                                SizedBox(height: 16.h),
                                Divider(
                                  height: 1,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.black.withValues(alpha: 0.05),
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  'تخصيص فئة وصيغة الإشعارات الصوتية:',
                                  style: TextStyle(
                                    fontSize: 14.5.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.primaryDark,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                _buildAudioCategoryCard(
                                  context: context,
                                  title: 'أدعية المرحومة / للفقيدة',
                                  subtitle: '7 مقاطع صوتية خاشعة بصيغة المؤنث (للأم، الأخت، الجدة...)',
                                  icon: LucideIcons.heart,
                                  target: AudioGenderTarget.femaleOnly,
                                  current: settings.audioGenderTarget,
                                  isDark: isDark,
                                ),
                                SizedBox(height: 8.h),
                                _buildAudioCategoryCard(
                                  context: context,
                                  title: 'أدعية المرحوم / للفقيد',
                                  subtitle: '8 مقاطع صوتية خاشعة بصيغة المذكر (للأب، الأخ، الجد...)',
                                  icon: LucideIcons.user,
                                  target: AudioGenderTarget.maleOnly,
                                  current: settings.audioGenderTarget,
                                  isDark: isDark,
                                ),
                                SizedBox(height: 8.h),
                                _buildAudioCategoryCard(
                                  context: context,
                                  title: 'كافة الأدعية والتسجيلات المباركة',
                                  subtitle: '15 مقطعاً صوتياً للتنويع والتناوب بين الأدعية',
                                  icon: LucideIcons.volume2,
                                  target: AudioGenderTarget.both,
                                  current: settings.audioGenderTarget,
                                  isDark: isDark,
                                ),
                                SizedBox(height: 16.h),
                                Divider(
                                  height: 1,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.black.withValues(alpha: 0.05),
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  'نمط تشغيل الصوت:',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Container(
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.darkBackground
                                        : AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(14.r),
                                    border: Border.all(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(14.r),
                                    child: RadioListTile<int>(
                                      value: 0,
                                      activeColor: AppColors.primary,
                                      groupValue: settings.selectedAudioIndex,
                                      title: const Text(
                                          'تتابع متسلسل في الفئة المحددة (صوت جديد كل فترة) 🔁'),
                                      subtitle: const Text(
                                          'الفترة الأولى صوت 1، الفترة التالية صوت 2... وهكذا في الفئة المختارة'),
                                      onChanged: (val) {
                                        if (val != null) {
                                          context
                                              .read<SettingsCubit>()
                                              .updateSelectedAudioIndex(val);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48.h,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14.r),
                                      ),
                                      elevation: 2,
                                    ),
                                    icon: Icon(LucideIcons.zap, size: 18.r),
                                    label: const Text(
                                        'تفعيل كافّة صلاحيات وقفل الشاشة ⚡'),
                                    onPressed: () =>
                                        _showLockScreenPermissionDialog(context),
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                SizedBox(
                                  width: double.infinity,
                                  height: 44.h,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      side: const BorderSide(
                                          color: AppColors.primary),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14.r),
                                      ),
                                    ),
                                    icon:
                                        Icon(LucideIcons.bellRing, size: 18.r),
                                    label: const Text(
                                        'تجربة إشعار وتسميع صوتي فوري الآن 🔊'),
                                    onPressed: () async {
                                      final duaCubit = context.read<DuaCubit>();
                                      final audioList =
                                          duaCubit.state.audioAzkar;
                                      if (audioList.isNotEmpty) {
                                        final notificationService =
                                            sl<NotificationService>();
                                        await notificationService
                                            .showInstantAudioNotification(
                                          audioItem: audioList.first,
                                          motherName: settings.motherName,
                                        );
                                      }
                                    },
                                  ),
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
                          activeThumbColor: Colors.white,
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
                          onChanged: (val) async {
                            if (val) {
                              await _requestNotificationPermissions(context);
                            }
                            if (context.mounted) {
                              context
                                  .read<SettingsCubit>()
                                  .toggleTextNotifications(val);
                            }
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
                            padding: EdgeInsets.all(16.r),
                            child: Column(
                              children: [
                                _buildSingleCustomTimeCard(
                                  context: context,
                                  isAudio: false,
                                  intervalMins: settings
                                      .getEffectiveTextIntervalMinutes(),
                                  isDark: isDark,
                                ),
                                SizedBox(height: 12.h),
                                SizedBox(
                                  width: double.infinity,
                                  height: 44.h,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      side: const BorderSide(
                                          color: AppColors.primary),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14.r),
                                      ),
                                    ),
                                    icon: Icon(LucideIcons.messageSquare,
                                        size: 18.r),
                                    label: const Text(
                                        'تجربة إشعار نصي فوري الآن 📖'),
                                    onPressed: () async {
                                      final duaCubit = context.read<DuaCubit>();
                                      final duaList = duaCubit.state.duas;
                                      if (duaList.isNotEmpty) {
                                        final notificationService =
                                            sl<NotificationService>();
                                        await notificationService
                                            .showInstantNotification(
                                          title: 'اللهم ارحم أمي 🤍',
                                          body: duaList.first.getFormattedText(
                                              settings.motherName),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
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

  String _formatIntervalText(int mins) {
    if (mins <= 0) return '1 دقيقة';
    if (mins < 60) return '$mins دقيقة';
    if (mins == 60) return 'ساعة واحدة';
    if (mins == 120) return 'ساعتين';
    if (mins % 60 == 0) return '${mins ~/ 60} ساعات';
    final h = mins ~/ 60;
    final m = mins % 60;
    return '$h ساعة و $m دقيقة';
  }

  Widget _buildSingleCustomTimeCard({
    required BuildContext context,
    required bool isAudio,
    required int intervalMins,
    required bool isDark,
  }) {
    final String intervalDisplay = _formatIntervalText(intervalMins);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkSurface, const Color(0xFF1B382B)]
              : [AppColors.surfaceVariant, Colors.white],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 14.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Current Duration Display Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8.r,
                    ),
                  ],
                ),
                child: Icon(
                  LucideIcons.timer,
                  color: AppColors.accentGold,
                  size: 24.r,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الوقت الفاصل للتكرار الحالي:',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'إشعار جديد كل: $intervalDisplay ⚡',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 18.h),

          // Single Primary Action Button
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 3,
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
              ),
              icon: Icon(LucideIcons.sliders, color: Colors.white, size: 20.r),
              label: Text(
                'تخصيص وتحديد الوقت بالدقائق ⏱️',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                _showCustomIntervalSheet(context, isAudio, intervalMins);
              },
            ),
          ),
        ],
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
                  'تخصيص وقت الإشعارات بحرية كاملة',
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

  Widget _buildAudioCategoryCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required AudioGenderTarget target,
    required AudioGenderTarget current,
    required bool isDark,
  }) {
    final isSelected = target == current;
    return InkWell(
      onTap: () {
        context.read<SettingsCubit>().updateAudioGenderTarget(target);
      },
      borderRadius: BorderRadius.circular(16.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? AppColors.primary.withValues(alpha: 0.18)
                  : AppColors.primary.withValues(alpha: 0.08))
              : (isDark
                  ? AppColors.darkBackground
                  : AppColors.surfaceVariant.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06)),
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 10.r,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.primary,
                size: 20.r,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22.r,
              height: 22.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textHint.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Icon(
                      LucideIcons.check,
                      color: Colors.white,
                      size: 14.r,
                    )
                  : null,
            ),
          ],
        ),
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
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
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
