import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:renjana/core/constants/app_typography.dart';
import '../constants/app_colors.dart';

class DetailSectionBlock extends StatelessWidget {
  final String title;
  final String content;
  final double dividerWidth;
  final EdgeInsetsGeometry padding;

  const DetailSectionBlock({
    super.key,
    required this.title,
    required this.content,
    this.dividerWidth = 48,
    this.padding = const EdgeInsets.fromLTRB(22, 0, 22, 24),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.editorialHeading()),
          const SizedBox(height: 4),
          Container(
            height: 1.5,
            width: dividerWidth,
            color: AppColors.primaryDark,
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
