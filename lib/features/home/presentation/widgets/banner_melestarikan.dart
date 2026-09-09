import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dekorasi.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_button.dart';

class BannerMelestarikan extends StatelessWidget {
  final VoidCallback? onContribute;

  const BannerMelestarikan({super.key, this.onContribute});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: AppDekorasi.radiusKartu,
          border: Border.all(color: AppColors.borderPrimary),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.history_edu_rounded,
              color: AppColors.primary,
              size: 44,
            ),
            const SizedBox(height: 12),
            Text(
              'Turut Melestarikan Sejarah',
              style: AppTypography.headingMedium(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Bantu kami melestarikan arsip dan narasi budaya yang belum tercatat. Setiap kontribusi bermakna.',
              style: AppTypography.bodyMedium(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Mulai Melestarikan',
              borderRadius: 6,
              onPressed: onContribute ?? () {},
            ),
          ],
        ),
      ),
    );
  }
}
