import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/app_colors.dart';
import '../../cubits/settings_cubit.dart';
import 'settings_shared_widgets.dart';

class SettingsSplashImageCard extends StatefulWidget {
  final String? customSplashImagePath;

  const SettingsSplashImageCard({
    super.key,
    required this.customSplashImagePath,
  });

  @override
  State<SettingsSplashImageCard> createState() => _SettingsSplashImageCardState();
}

class _SettingsSplashImageCardState extends State<SettingsSplashImageCard> {
  bool _isPickingImage = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customPath = widget.customSplashImagePath;
    final hasCustomFile = customPath != null &&
        customPath.isNotEmpty &&
        File(customPath).existsSync();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader(
          title: 'صورة شاشة البداية (Splash Screen) 🖼️',
          subtitle: 'تغيير وتخصيص الصورة المعروضة عند فتح التطبيق من المعرض',
          icon: LucideIcons.image,
        ),
        SizedBox(height: 12.h),
        SettingsCardContainer(
          child: Column(
            children: [
              Container(
                height: 220.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBackground : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18.5.r),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: hasCustomFile
                            ? Image.file(
                                File(customPath),
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
                                        ? [const Color(0xFF1B382B), AppColors.darkSurface]
                                        : [AppColors.surfaceVariant, Colors.white],
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(16.r),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primary.withValues(alpha: 0.12),
                                        border: Border.all(
                                          color: AppColors.accentGold.withValues(alpha: 0.4),
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
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          LucideIcons.sparkles,
                                          size: 14.r,
                                          color: AppColors.accentGold,
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          'أيقونة الصدقة الجارية الافتراضية',
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      Positioned(
                        top: 10.h,
                        right: 10.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            color: (hasCustomFile ? AppColors.primary : AppColors.accentGold)
                                .withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 6.r,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                hasCustomFile ? LucideIcons.checkCircle2 : LucideIcons.image,
                                size: 13.r,
                                color: Colors.white,
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                hasCustomFile ? 'صورة مخصصة ✨' : 'الأيقونة الافتراضية 🕊️',
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
                        side: const BorderSide(color: AppColors.primary),
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
                              final settingsCubit = context.read<SettingsCubit>();
                              final messenger = ScaffoldMessenger.of(context);

                              setState(() => _isPickingImage = true);
                              try {
                                final result = await FilePicker.platform.pickFiles(
                                  type: FileType.image,
                                  allowMultiple: false,
                                );
                                if (result != null &&
                                    result.files.single.path != null &&
                                    mounted) {
                                  final imagePath = result.files.single.path!;
                                  String savedPath = imagePath;
                                  try {
                                    final pickedFile = File(imagePath);
                                    final persistentDir = Directory(
                                        '${pickedFile.parent.parent.path}/persistent_splash');
                                    if (!persistentDir.existsSync()) {
                                      await persistentDir.create(recursive: true);
                                    }
                                    final extension = pickedFile.path.split('.').last;
                                    final targetFile = File(
                                        '${persistentDir.path}/splash_image.$extension');
                                    await pickedFile.copy(targetFile.path);
                                    savedPath = targetFile.path;
                                  } catch (_) {}

                                  if (!mounted) return;

                                  settingsCubit.updateCustomSplashImagePath(savedPath);
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(LucideIcons.checkCircle2,
                                              color: Colors.white, size: 20.r),
                                          SizedBox(width: 10.w),
                                          const Expanded(
                                            child: Text(
                                              'تم تحديث صورة شاشة البداية بنجاح 🖼️',
                                              style: TextStyle(fontWeight: FontWeight.bold),
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
                              } catch (e) {
                                debugPrint('File picker error: $e');
                              } finally {
                                if (mounted) {
                                  setState(() => _isPickingImage = false);
                                }
                              }
                            },
                    ),
                  ),
                  if (customPath != null) ...[
                    SizedBox(width: 10.w),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
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
                        context.read<SettingsCubit>().updateCustomSplashImagePath(null);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(LucideIcons.checkCircle2, color: Colors.white, size: 20.r),
                                SizedBox(width: 10.w),
                                const Expanded(
                                  child: Text(
                                    'تمت استعادة الصورة الافتراضية 🔄',
                                    style: TextStyle(fontWeight: FontWeight.bold),
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
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
