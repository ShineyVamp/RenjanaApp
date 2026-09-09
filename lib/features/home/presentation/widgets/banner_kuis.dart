import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dekorasi.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_button.dart';

class BannerKuis extends StatelessWidget {
  final VoidCallback? onStartQuiz;

  const BannerKuis({super.key, this.onStartQuiz});

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
              Icons.quiz_outlined,
              color: AppColors.primary,
              size: 44,
            ),
            const SizedBox(height: 12),
            Text(
              'Uji Pengetahuan Nusantara',
              style: AppTypography.headingMedium(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tantang wawasanmu seputar sejarah, budaya, dan tradisi daerah Indonesia lewat kuis interaktif.',
              style: AppTypography.bodyMedium(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Jelajahi Kuis',
              borderRadius: 6,
              onPressed: onStartQuiz ?? () {},
            ),
          ],
        ),
      ),
    );
  }
}
