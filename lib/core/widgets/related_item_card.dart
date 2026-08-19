import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

class RelatedItemCard extends StatelessWidget {
  final String inventoryCode;
  final String title;
  final String? imagePath;
  final VoidCallback? onTap;

  const RelatedItemCard({
    super.key,
    required this.inventoryCode,
    required this.title,
    this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 155,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  color: AppColors.surfaceMuted,
                  child: imagePath != null
                      ? Image.asset(imagePath!, fit: BoxFit.cover)
                      : const Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 28,
                            color: Colors.white70,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              inventoryCode,
              style: AppTypography.tag(color: AppColors.primaryDark),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.editorialSubheading(
                color: AppColors.textPrimary,
              ).copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
