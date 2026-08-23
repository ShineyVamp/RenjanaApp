import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dekorasi.dart';
import '../constants/app_typography.dart';

// Ajakan melaporkan kekeliruan pada arsip yang sedang dibaca. Dipasang di
// halaman detail sejarah dan budaya.
class TombolKoreksi extends StatelessWidget {
  final VoidCallback onTap;
  final EdgeInsetsGeometry padding;

  const TombolKoreksi({
    super.key,
    required this.onTap,
    this.padding = const EdgeInsets.fromLTRB(22, 0, 22, 0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: AppDekorasi.panel(garis: AppColors.border),
          child: Row(
            children: [
              const Icon(
                Icons.flag_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ada yang keliru di arsip ini?',
                      style: AppTypography.labelBold(fontSize: 12.5),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Usulkan koreksi, admin akan meninjaunya.',
                      style: AppTypography.caption(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
