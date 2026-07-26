import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../app/app_colors.dart';

class SurahFatihaCard extends StatelessWidget {
  const SurahFatihaCard({super.key});

  static const List<String> _fatihaAyahs = [
    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
    'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
    'الرَّحْمَٰنِ الرَّحِيمِ',
    'مَالِكِ يَوْمِ الدِّينِ',
    'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
    'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
    'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
  ];

  static String _toArabicDigits(int number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String str = number.toString();
    for (int i = 0; i < english.length; i++) {
      str = str.replaceAll(english[i], arabic[i]);
    }
    return str;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isDark
              ? AppColors.primaryLight.withValues(alpha: 0.2)
              : AppColors.primary.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 16.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Header Icon
            Icon(
              LucideIcons.bookOpen,
              size: 28.r,
              color: AppColors.primary,
            ),
            SizedBox(height: 8.h),
            Text(
              'سُورَةُ الفَاتِحَةِ',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.primaryDark,
              ),
            ),
            SizedBox(height: 16.h),
            Divider(
              color: AppColors.accentGold.withValues(alpha: 0.3),
              thickness: 1,
              indent: 40.w,
              endIndent: 40.w,
            ),
            SizedBox(height: 16.h),
            // Dynamic Quran Text with Gold Verse Markers
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w600,
                  height: 2.2,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
                children: _buildAyahTextSpans(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<InlineSpan> _buildAyahTextSpans() {
    final List<InlineSpan> spans = [];
    for (int i = 0; i < _fatihaAyahs.length; i++) {
      final verseNum = _toArabicDigits(i + 1);
      spans.add(TextSpan(text: '${_fatihaAyahs[i]} '));
      spans.add(
        TextSpan(
          text: '﴿$verseNum﴾${i < _fatihaAyahs.length - 1 ? " " : ""}',
          style: const TextStyle(
            color: AppColors.accentGold,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return spans;
  }
}
