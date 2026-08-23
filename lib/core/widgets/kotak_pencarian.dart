import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../constants/app_dekorasi.dart';

// Kotak pencarian bergaris tunggal, dipakai daftar arsip daerah dan daftar
// tema kuis.
class KotakPencarian extends StatelessWidget {
  final TextEditingController controller;
  final String petunjuk;
  final ValueChanged<String> onChanged;
  final VoidCallback onBersihkan;

  const KotakPencarian({
    super.key,
    required this.controller,
    required this.petunjuk,
    required this.onChanged,
    required this.onBersihkan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: AppDekorasi.panel(),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: petunjuk,
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: onBersihkan,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
