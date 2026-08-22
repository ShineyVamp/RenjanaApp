import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/hasil_jelajah_model.dart';
import '../constants/app_colors.dart';
import 'app_image.dart';

// Kartu baris hasil, dipakai di Jelajah, halaman provinsi, dan daftar arsip.
class KartuHasil extends StatelessWidget {
  final HasilJelajah item;
  final VoidCallback onTap;

  // Gambar memenuhi tinggi kartu, dipakai saat kartu berada di kotak
  // bertinggi tetap.
  final bool isiPenuh;

  const KartuHasil({
    super.key,
    required this.item,
    required this.onTap,
    this.isiPenuh = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.borderPrimary),
        ),
        child: Row(
          crossAxisAlignment: isiPenuh
              ? CrossAxisAlignment.stretch
              : CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 104,
              child: isiPenuh
                  ? AppImageView(imagePath: item.gambar, fit: BoxFit.cover)
                  : AspectRatio(
                      aspectRatio: 1,
                      child: AppImageView(
                        imagePath: item.gambar,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        LencanaKecil(
                          teks: item.kodeTag,
                          warna: item.isWilayah
                              ? AppColors.primaryDark
                              : AppColors.primary,
                        ),
                        if (item.isDestinasi) ...[
                          const SizedBox(width: 6),
                          const LencanaKecil(
                            teks: 'DESTINASI',
                            warna: AppColors.accentBudaya,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.judul,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 19,
                        color: AppColors.textPrimary,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.sub,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.meta.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LencanaKecil extends StatelessWidget {
  final String teks;
  final Color warna;

  const LencanaKecil({super.key, required this.teks, required this.warna});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      color: warna,
      child: Text(
        teks,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.7,
          color: Colors.white,
        ),
      ),
    );
  }
}
