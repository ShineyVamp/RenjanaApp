import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

// Section detail berisi baris bernomor, mis. bahan masakan, langkah memasak,
// atau tokoh cerita. Judul dan garisnya mengikuti DetailSectionBlock.
class DetailListBlock extends StatelessWidget {
  final String title;
  final List<String> items;
  final double dividerWidth;
  final EdgeInsetsGeometry padding;

  const DetailListBlock({
    super.key,
    required this.title,
    required this.items,
    this.dividerWidth = 48,
    this.padding = const EdgeInsets.fromLTRB(22, 0, 22, 24),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          ...List.generate(items.length, (index) {
            final terakhir = index == items.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: terakhir ? 0 : 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 26,
                    child: Text(
                      '${index + 1}'.padLeft(2, '0'),
                      style: AppTypography.tag(color: AppColors.primaryDark),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      items[index],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        height: 1.55,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
