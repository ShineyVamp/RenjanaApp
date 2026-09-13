import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dekorasi.dart';
import '../../../../core/widgets/app_image.dart';
import 'package:renjana/features/capaian/data/repositories/lencana_repository.dart';

// Lambang satu lencana: logo yang disetel admin bila ada, ikon bawaan bila
// belum. Dipakai panel profil, halaman lencana, dan halaman admin.
class KepingLencana extends StatelessWidget {
  final StatusLencana status;
  final double ukuran;

  const KepingLencana({super.key, required this.status, this.ukuran = 52});

  IconData _ikonBawaan(String kode, bool terbuka) {
    if (!terbuka) return Icons.lock_outline_rounded;
    if (kode.startsWith('RTN')) return Icons.local_fire_department_rounded;
    if (kode.startsWith('ARS')) return Icons.menu_book_rounded;
    if (kode.startsWith('KAT')) return Icons.auto_awesome_rounded;
    if (kode.startsWith('PLU')) return Icons.explore_rounded;
    if (kode.startsWith('PRD')) return Icons.history_edu_rounded;
    if (kode.startsWith('USL')) return Icons.volunteer_activism_rounded;
    return Icons.military_tech_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final terbuka = status.terbuka;
    final warna = terbuka ? AppColors.gold : AppColors.border;
    final adaLogo = status.gambar.trim().isNotEmpty;

    return Container(
      width: ukuran,
      height: ukuran,
      alignment: Alignment.center,
      clipBehavior: adaLogo ? Clip.antiAlias : Clip.none,
      decoration: BoxDecoration(
        color: terbuka
            ? AppColors.gold.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: AppDekorasi.radiusKecil,
        border: Border.all(color: warna, width: terbuka ? 1.4 : 1),
      ),
      child: adaLogo
          ? AppImageView(imagePath: status.gambar, fit: BoxFit.cover)
          : Icon(
              _ikonBawaan(status.lencana.kode, terbuka),
              size: ukuran * 0.46,
              color: terbuka ? AppColors.gold : AppColors.surfaceMuted,
            ),
    );
  }
}
