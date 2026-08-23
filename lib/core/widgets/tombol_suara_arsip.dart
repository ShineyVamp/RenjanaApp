import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../../services/pembaca_arsip.dart';

// Komponen pemutar suara / audio reader yang disematkan di halaman detail arsip.
class TombolSuaraArsip extends StatefulWidget {
  final String teksNarasi;
  final String judul;

  const TombolSuaraArsip({
    super.key,
    required this.teksNarasi,
    this.judul = 'Narasi Arsip',
  });

  @override
  State<TombolSuaraArsip> createState() => _TombolSuaraArsipState();
}

class _TombolSuaraArsipState extends State<TombolSuaraArsip> {
  final PembacaArsip _pembaca = PembacaArsip();

  @override
  void initState() {
    super.initState();
    _pembaca.onStatusBerubah = (status) {
      if (mounted) setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    final sedangMembaca = _pembaca.sedangMembaca;
    final sedangJeda = _pembaca.sedangJeda;
    final aktif = _pembaca.aktif;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: aktif
              ? AppColors.primary.withAlpha(25)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: aktif ? AppColors.primary : AppColors.border,
            width: aktif ? 1.5 : 1.0,
          ),
          boxShadow: [
            if (aktif)
              BoxShadow(
                color: AppColors.primary.withAlpha(20),
                blurRadius: 8,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Row(
          children: [
            // Tombol Putar / Jeda
            GestureDetector(
              onTap: () => _pembaca.toggle(widget.teksNarasi),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  sedangMembaca
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Teks Keterangan
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    sedangMembaca
                        ? 'Sedang Membacakan...'
                        : (sedangJeda ? 'Audio Dijeda' : 'Dengarkan Narasi'),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sedangMembaca || sedangJeda
                        ? widget.judul
                        : 'Putar suara audio reader bahasa Indonesia',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Tombol Stop bila aktif
            if (aktif) ...[
              IconButton(
                icon: const Icon(
                  Icons.stop_circle_outlined,
                  color: AppColors.error,
                  size: 24,
                ),
                tooltip: 'Berhenti',
                onPressed: () => _pembaca.berhenti(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
