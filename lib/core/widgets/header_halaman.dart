import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

// Header seragam untuk halaman tab utama: judul besar, garis merah pendek,
// dan opsional keterangan di kanan judul serta isian tambahan di bawahnya.
class HeaderHalaman extends StatelessWidget {
  final String judul;
  final Widget? aksi; // sederet dengan judul, rata kanan
  final Widget? bawah; // di bawah garis, mis. kotak pencarian
  final bool garisBawah;

  // Tepi header, diisi bila induknya sudah punya padding sendiri.
  final EdgeInsetsGeometry? padding;

  const HeaderHalaman({
    super.key,
    required this.judul,
    this.aksi,
    this.bawah,
    this.garisBawah = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ?? EdgeInsets.fromLTRB(20, 8, 20, bawah == null ? 12 : 14),
      decoration: BoxDecoration(
        border: garisBawah
            ? const Border(
                bottom: BorderSide(color: AppColors.primary, width: 0.8),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  judul,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 32,
                    height: 1.1,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (aksi != null)
                Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 5),
                  child: aksi,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Container(width: 80, height: 2.5, color: AppColors.primary),
          if (bawah != null) ...[const SizedBox(height: 14), bawah!],
        ],
      ),
    );
  }
}
