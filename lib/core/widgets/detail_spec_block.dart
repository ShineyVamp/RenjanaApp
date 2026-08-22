import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

class SpecItem {
  final String label;
  final String nilai;

  const SpecItem(this.label, this.nilai);
}

// Kotak data singkat di bawah deskripsi, berisi keterangan pendek seperti
// tahun berdiri atau jumlah pemain.
class DetailSpecBlock extends StatelessWidget {
  final List<SpecItem> items;
  final EdgeInsetsGeometry padding;

  const DetailSpecBlock({
    super.key,
    required this.items,
    this.padding = const EdgeInsets.fromLTRB(22, 0, 22, 24),
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: padding,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.borderPrimary),
        ),
        child: Column(
          children: List.generate(items.length, (index) {
            final terakhir = index == items.length - 1;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: terakhir
                    ? null
                    : const Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    items[index].label.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    items[index].nilai,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
