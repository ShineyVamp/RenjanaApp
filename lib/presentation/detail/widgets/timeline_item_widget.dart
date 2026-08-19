import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/app_image.dart';

class TimelineItemWidget extends StatelessWidget {
  final String date;
  final String title;
  final String description;
  final String? imagePath;
  final bool isLast;

  const TimelineItemWidget({
    super.key,
    required this.date,
    required this.title,
    required this.description,
    this.imagePath,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Vertical Timeline Line
        if (!isLast)
          Positioned(
            top: 8,
            bottom: -10,
            left: 3,
            child: Container(
              width: 1.5,
              color: AppColors.border,
            ),
          ),

        // Timeline Indicator Square
        Positioned(
          top: 4,
          left: 0,
          child: Container(
            width: 7.5,
            height: 7.5,
            color: AppColors.primaryDark,
          ),
        ),

        // Timeline Content
        Padding(
          padding: const EdgeInsets.only(left: 22, bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: AppTypography.tag(color: AppColors.primaryDark),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: AppTypography.editorialHeading(
                  color: AppColors.textPrimary,
                ).copyWith(fontSize: 21, height: 1.18),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: AppTypography.bodyMedium(color: AppColors.textSecondary),
              ),
              if (imagePath != null && imagePath!.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: AppImageView(
                      imagePath: imagePath!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
