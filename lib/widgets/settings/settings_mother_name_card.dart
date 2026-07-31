import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/app_colors.dart';
import '../../cubits/settings_cubit.dart';
import 'settings_shared_widgets.dart';

class SettingsMotherNameCard extends StatefulWidget {
  final String initialName;

  const SettingsMotherNameCard({
    super.key,
    required this.initialName,
  });

  @override
  State<SettingsMotherNameCard> createState() => _SettingsMotherNameCardState();
}

class _SettingsMotherNameCardState extends State<SettingsMotherNameCard> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void didUpdateWidget(covariant SettingsMotherNameCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialName != widget.initialName &&
        _nameController.text != widget.initialName) {
      _nameController.text = widget.initialName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader(
          title: 'اسم الوالدة المتوفاة 🤍',
          subtitle: 'تخصيص نص ونية الدعاء باسمها في كافة الشاشات والإشعارات',
          icon: LucideIcons.heart,
        ),
        SizedBox(height: 12.h),
        SettingsCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                keyboardType: TextInputType.name,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'أدخل اسم الوالدة هنا...',
                  prefixIcon: Icon(
                    LucideIcons.user,
                    color: AppColors.primary,
                    size: 20.r,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.darkBackground : AppColors.surfaceVariant,
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
                  icon: Icon(LucideIcons.save, color: Colors.white, size: 18.r),
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
                    context.read<SettingsCubit>().updateMotherName(name);
                    FocusScope.of(context).unfocus();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(LucideIcons.checkCircle2, color: Colors.white, size: 20.r),
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
      ],
    );
  }
}
