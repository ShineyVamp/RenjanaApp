import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';

// Kartu angka pendek pada halaman pulau dan provinsi.
class KartuStatistik extends StatelessWidget {
  final IconData ikon;
  final String label;
  final String nilai;

  const KartuStatistik({
    super.key,
    required this.ikon,
    required this.label,
    required this.nilai,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.borderPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, size: 20, color: AppColors.primary),
          const SizedBox(height: 10),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            nilai,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 22,
              height: 1.15,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
