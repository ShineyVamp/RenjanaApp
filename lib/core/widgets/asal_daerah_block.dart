import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../constants/wilayah_nusantara.dart';

// Penanda asal daerah pada halaman detail arsip. Tautan "Lihat provinsi"
// hanya muncul bila [onLihatProvinsi] diisi.
class AsalDaerahBlock extends StatelessWidget {
  final String? namaProvinsi;
  final VoidCallback? onLihatProvinsi;
  final EdgeInsetsGeometry padding;

  const AsalDaerahBlock({
    super.key,
    required this.namaProvinsi,
    this.onLihatProvinsi,
    this.padding = const EdgeInsets.fromLTRB(22, 0, 22, 26),
  });

  @override
  Widget build(BuildContext context) {
    final provinsi = provinsiDariNama(namaProvinsi);
    if (provinsi == null) return const SizedBox.shrink();

    final pulau = pulauDariProvinsi(provinsi.nama);

    return Padding(
      padding: padding,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderPrimary),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.place_outlined,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provinsi.nama,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (pulau != null)
                    Text(
                      'Pulau ${pulau.nama}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            if (onLihatProvinsi != null)
              GestureDetector(
                onTap: onLihatProvinsi,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    'Lihat provinsi ›',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
