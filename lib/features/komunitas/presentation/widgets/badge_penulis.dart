import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../capaian/data/models/lencana_model.dart';

// widget badge dan lencana penulis
class BadgePenulis extends StatelessWidget {
  final String role;
  final String gelar;
  final List<String> badgePilihan;
  final String? waktuTeks;

  const BadgePenulis({
    super.key,
    required this.role,
    required this.gelar,
    this.badgePilihan = const [],
    this.waktuTeks,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == 'admin';

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 4,
      children: [
        // label role atau gelar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
          decoration: BoxDecoration(
            color: isAdmin
                ? AppColors.primary
                : AppColors.primaryDark.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isAdmin ? AppColors.primaryDark : AppColors.borderLight,
              width: 0.8,
            ),
          ),
          child: Text(
            isAdmin ? 'ADMIN' : gelar.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              color: isAdmin ? Colors.white : AppColors.primaryDark,
            ),
          ),
        ),

        // pin lencana pilihan
        if (badgePilihan.isNotEmpty)
          ...badgePilihan.take(3).map((kode) {
            Lencana? lencana;
            try {
              lencana = lencanaKatalog.firstWhere((l) => l.kode == kode);
            } catch (_) {}

            return Tooltip(
              message: lencana?.nama ?? kode,
              child: Container(
                width: 17,
                height: 17,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withValues(alpha: 0.15),
                  border: Border.all(color: AppColors.gold, width: 1),
                ),
                child: const Icon(
                  Icons.military_tech_rounded,
                  size: 11,
                  color: AppColors.gold,
                ),
              ),
            );
          }),

        // waktu teks bila ada
        if (waktuTeks != null && waktuTeks!.isNotEmpty) ...[
          Text(
            '· $waktuTeks',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}
