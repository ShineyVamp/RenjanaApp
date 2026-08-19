import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final double dividerWidth;
  final bool isCenter;

  const SectionHeader({
    super.key,
    required this.title,
    this.dividerWidth = 48,
    this.isCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isCenter ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.editorialHeading(color: AppColors.textPrimary),
          textAlign: isCenter ? TextAlign.center : TextAlign.start,
        ),
        const SizedBox(height: 4),
        Container(
          height: 1.5,
          width: dividerWidth,
          color: AppColors.primaryDark,
        ),
      ],
    );
  }
}

class SectionBadgeTitle extends StatelessWidget {
  final String title;

  const SectionBadgeTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Text(
        title,
        style: AppTypography.tag(color: Colors.white).copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
