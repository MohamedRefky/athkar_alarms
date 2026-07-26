import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../app/app_colors.dart';

class AudioPlayerBar extends StatelessWidget {
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final VoidCallback onTogglePlay;
  final VoidCallback onStop;

  const AudioPlayerBar({
    super.key,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.onTogglePlay,
    required this.onStop,
  });

  String _formatDuration(Duration dur) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(dur.inMinutes.remainder(60));
    final seconds = twoDigits(dur.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final maxSec = duration.inSeconds > 0 ? duration.inSeconds.toDouble() : 1.0;
    final currentSec = position.inSeconds.toDouble().clamp(0.0, maxSec);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onTogglePlay,
            icon: Icon(
              isPlaying ? LucideIcons.pause : LucideIcons.play,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            _formatDuration(position),
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 4.h,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 14.r),
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.primary.withValues(alpha: 0.2),
                thumbColor: AppColors.primary,
              ),
              child: Slider(
                value: currentSec,
                max: maxSec,
                onChanged: (_) {},
              ),
            ),
          ),
          Text(
            _formatDuration(duration),
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: onStop,
            icon: const Icon(LucideIcons.x, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}
