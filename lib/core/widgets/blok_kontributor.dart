import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dekorasi.dart';
import '../constants/app_typography.dart';

// Pengakuan bagi pengguna yang mengusulkan arsip ini. Tidak muncul pada arsip
// bawaan aplikasi, yang kolom kontributornya memang kosong.
class BlokKontributor extends StatelessWidget {
  final String? nama;
  final EdgeInsetsGeometry padding;

  const BlokKontributor({
    super.key,
    required this.nama,
    this.padding = const EdgeInsets.fromLTRB(22, 0, 22, 14),
  });

  @override
  Widget build(BuildContext context) {
    final bersih = (nama ?? '').trim();
    if (bersih.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: padding,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: AppDekorasi.panelCapaian(AppColors.gold),
        child: Row(
          children: [
            const Icon(
              Icons.volunteer_activism_rounded,
              size: 18,
              color: AppColors.gold,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DIKONTRIBUSIKAN OLEH', style: AppTypography.eyebrow()),
                  const SizedBox(height: 2),
                  Text(bersih, style: AppTypography.labelBold(fontSize: 13.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
