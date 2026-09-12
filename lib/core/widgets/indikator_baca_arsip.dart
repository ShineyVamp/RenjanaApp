import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

// widget indikator durasi baca arsip
class IndikatorBacaArsip extends StatelessWidget {
  final int detikTersisa;
  final bool sudahSelesai;
  final int totalDetik;

  const IndikatorBacaArsip({
    super.key,
    required this.detikTersisa,
    required this.sudahSelesai,
    this.totalDetik = 10,
  });

  @override
  Widget build(BuildContext context) {
    final double progres = sudahSelesai
        ? 1.0
        : ((totalDetik - detikTersisa) / totalDetik).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: sudahSelesai
            ? Colors.green.withValues(alpha: 0.08)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: sudahSelesai
              ? Colors.green.withValues(alpha: 0.3)
              : AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                sudahSelesai
                    ? Icons.check_circle_rounded
                    : Icons.timer_outlined,
                size: 18,
                color: sudahSelesai ? Colors.green : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  sudahSelesai
                      ? 'Selesai dibaca (+Poin Capaian)'
                      : 'Baca $detikTersisa detik untuk menyelesaikan arsip',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: sudahSelesai
                        ? Colors.green.shade800
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (!sudahSelesai) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progres,
                minHeight: 3,
                backgroundColor: AppColors.border.withValues(alpha: 0.4),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
