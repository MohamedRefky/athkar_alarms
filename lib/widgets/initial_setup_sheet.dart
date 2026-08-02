import 'dart:io';

import 'package:azkar/services/preferences_service.dart';
import 'package:azkar/services/service_locator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../app/app_colors.dart';
import '../cubits/dua_cubit.dart';
import '../cubits/settings_cubit.dart';
import '../models/settings_model.dart';

class InitialSetupSheet extends StatefulWidget {
  const InitialSetupSheet({super.key});

  static Future<void> show(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      builder: (_) => const InitialSetupSheet(),
    );
  }

  @override
  State<InitialSetupSheet> createState() => _InitialSetupSheetState();
}

class _InitialSetupSheetState extends State<InitialSetupSheet> {
  late TextEditingController _nameController;
  String? _pickedImagePath;
  late AudioGenderTarget _selectedGenderTarget;
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsCubit>().state.settings;
    _nameController = TextEditingController(text: settings.motherName);
    _pickedImagePath = settings.customSplashImagePath;
    _selectedGenderTarget = settings.audioGenderTarget;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() => _isPickingImage = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null && mounted) {
        final rawPath = result.files.single.path!;
        // Copy to persistent directory
        String savedPath = rawPath;
        try {
          final pickedFile = File(rawPath);
          final persistentDir =
              Directory('${pickedFile.parent.parent.path}/persistent_splash');
          if (!persistentDir.existsSync()) {
            await persistentDir.create(recursive: true);
          }
          final extension = pickedFile.path.split('.').last;
          final targetFile =
              File('${persistentDir.path}/splash_image.$extension');
          await pickedFile.copy(targetFile.path);
          savedPath = targetFile.path;
        } catch (_) {}

        setState(() {
          _pickedImagePath = savedPath;
        });
      }
    } catch (e) {
      debugPrint('File picker error: $e');
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  void _saveAndClose() async {
    final name = _nameController.text.trim();
    final settingsCubit = context.read<SettingsCubit>();
    final duaCubit = context.read<DuaCubit>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // Update name
    settingsCubit.updateMotherName(name);

    // Update audio gender target
    settingsCubit.updateAudioGenderTarget(_selectedGenderTarget);

    // Update image
    settingsCubit.updateCustomSplashImagePath(_pickedImagePath);

    // Mark first time setup as completed so it NEVER shows again
    final prefs = sl<PreferencesService>();
    await prefs.setHasCompletedInitialSetup(true);

    if (!mounted) return;

    // Reschedule notifications with new name/image
    settingsCubit.rescheduleNotifications(
      duas: duaCubit.state.duas,
      audioAzkar: duaCubit.state.audioAzkar,
      onlyIfEmpty: false,
    );

    navigator.pop();

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(LucideIcons.checkCircle2, color: Colors.white, size: 20.r),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                name.isNotEmpty
                    ? 'تم حفظ بيانات "$name" وتخصيص التطبيق والإشعارات 🤍'
                    : 'تم تخصيص التطبيق بنجاح 🤍',
                style: const TextStyle(fontWeight: FontWeight.bold),
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
  }

  void _skipAndClose() async {
    final prefs = sl<PreferencesService>();
    await prefs.setHasCompletedInitialSetup(true);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasImage = _pickedImagePath != null &&
        _pickedImagePath!.isNotEmpty &&
        File(_pickedImagePath!).existsSync();

    return Padding(
      padding: EdgeInsets.only(
        left: 22.w,
        right: 22.w,
        top: 16.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          // Drag Handle
          Container(
            width: 48.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: AppColors.textHint.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
          SizedBox(height: 18.h),

          // Header Badge Icon
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              gradient: SweepGradient(
                colors: [
                  AppColors.accentGold,
                  AppColors.primary,
                  AppColors.primaryDark,
                  AppColors.accentGold,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 16.r,
                  spreadRadius: 2.r,
                ),
              ],
            ),
            child: Icon(
              Icons.volunteer_activism,
              color: Colors.white,
              size: 32.r,
            ),
          ),
          SizedBox(height: 14.h),

          // Title
          Text(
            'تخصيص التطبيق لفقيدك الغالي 🤍',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
            ),
          ),
          SizedBox(height: 6.h),

          // Subtitle
          Text(
            'أدخل اسم وصورة الفقيد واختر أصوات الإشعارات المناسبة بنية الدعاء له والصدقة الجارية باسمه.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: 18.h),

          // Name Input Field
          TextFormField(
            controller: _nameController,
            keyboardType: TextInputType.name,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'أدخل اسم المتوفى هنا...',
              hintStyle:
                  TextStyle(fontSize: 13.5.sp, color: AppColors.textHint),
              prefixIcon: Icon(
                LucideIcons.userCheck,
                color: AppColors.primary,
                size: 20.r,
              ),
              filled: true,
              fillColor:
                  isDark ? AppColors.darkBackground : AppColors.surfaceVariant,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.8,
                ),
              ),
            ),
          ),
          SizedBox(height: 14.h),

          // Audio Gender Target Selection Header
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'أصوات الإشعارات الصوتية المرغوبة:',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(height: 8.h),

          // Gender Selection Segmented Options
          Row(
            children: [
              _buildSetupTargetChip(
                target: AudioGenderTarget.femaleOnly,
                label: 'أدعية المرحومة',
                icon: LucideIcons.heart,
                isDark: isDark,
              ),
              SizedBox(width: 8.w),
              _buildSetupTargetChip(
                target: AudioGenderTarget.maleOnly,
                label: 'أدعية المرحوم',
                icon: LucideIcons.userCheck,
                isDark: isDark,
              ),
              SizedBox(width: 8.w),
              _buildSetupTargetChip(
                target: AudioGenderTarget.both,
                label: 'كافة الأصوات',
                icon: LucideIcons.layers,
                isDark: isDark,
              ),
            ],
          ),

          SizedBox(height: 14.h),

          // Custom Picture Picker Container
          InkWell(
            onTap: _isPickingImage ? null : _pickImage,
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBackground
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: (hasImage ? AppColors.primary : AppColors.accentGold)
                      .withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  // Image Thumbnail or Icon
                  Container(
                    width: 54.r,
                    height: 54.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.1),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: ClipOval(
                      child: hasImage
                          ? Image.file(
                              File(_pickedImagePath!),
                              fit: BoxFit.cover,
                              width: 54.r,
                              height: 54.r,
                            )
                          : Icon(
                              LucideIcons.camera,
                              color: AppColors.primary,
                              size: 24.r,
                            ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasImage
                              ? 'تم اختيار صورة الفقيد ✨'
                              : 'إضافة صورة للمتوفى (اختياري) 🖼️',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          hasImage
                              ? 'اضغط لتغيير الصورة المختارة'
                              : 'تظهر الصورة في شاشة البداية والإعدادات',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasImage)
                    IconButton(
                      icon: Icon(LucideIcons.x,
                          color: AppColors.error, size: 20.r),
                      onPressed: () {
                        setState(() {
                          _pickedImagePath = null;
                        });
                      },
                    )
                  else
                    Icon(
                      LucideIcons.chevronLeft,
                      color: AppColors.primary,
                      size: 20.r,
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // Primary Save Button
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 4,
                shadowColor: AppColors.primary.withValues(alpha: 0.4),
              ),
              icon: Icon(LucideIcons.sparkles, color: Colors.white, size: 20.r),
              label: Text(
                'حفظ وتخصيص التطبيق ⚡',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onPressed: _saveAndClose,
            ),
          ),

          SizedBox(height: 8.h),

          // Secondary Skip Button
          TextButton(
            onPressed: _skipAndClose,
            child: Text(
              'المتابعة كصدقة عامة والتعديل لاحقاً',
              style: TextStyle(
                fontSize: 13.5.sp,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }

  Widget _buildSetupTargetChip({
    required AudioGenderTarget target,
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _selectedGenderTarget == target;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedGenderTarget = target;
          });
        },
        borderRadius: BorderRadius.circular(12.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : (isDark
                    ? AppColors.darkBackground
                    : AppColors.surfaceVariant),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14.r,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary),
              ),
              SizedBox(width: 5.w),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
