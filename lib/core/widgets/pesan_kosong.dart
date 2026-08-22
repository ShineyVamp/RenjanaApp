import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

// Keterangan saat sebuah daftar tidak berisi apa pun.
class PesanKosong extends StatelessWidget {
  final String pesan;
  final IconData ikon;

  const PesanKosong({
    super.key,
    required this.pesan,
    this.ikon = Icons.inventory_2_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, size: 46, color: AppColors.surfaceMuted),
          const SizedBox(height: 12),
          Text(
            pesan,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium(),
          ),
        ],
      ),
    );
  }
}
