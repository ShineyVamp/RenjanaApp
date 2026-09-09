import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dekorasi.dart';
import '../../../../core/constants/app_typography.dart';
import 'package:renjana/features/kontribusi/data/models/usulan_model.dart';

// Satu baris usulan pada daftar. Dipakai halaman Kontribusi Saya dan panel
// admin, karena keduanya menampilkan ringkasan yang sama.
class KartuUsulan extends StatelessWidget {
  final Usulan usulan;
  final VoidCallback onTap;

  // Diisi di panel admin; pada halaman pengguna tidak perlu, sebab semuanya
  // milik dia sendiri.
  final String? namaPengusul;

  const KartuUsulan({
    super.key,
    required this.usulan,
    required this.onTap,
    this.namaPengusul,
  });

  static const List<String> _namaBulan = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static String tanggal(DateTime waktu) =>
      '${waktu.day} ${_namaBulan[waktu.month - 1]} ${waktu.year}';

  @override
  Widget build(BuildContext context) {
    final status = usulan.status;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
        decoration: AppDekorasi.panelCapaian(status.warna),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(usulan.jenis.ikon, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    usulan.judul.isEmpty ? 'Tanpa judul' : usulan.judul,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelBold(fontSize: 13.5),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    [
                      usulan.koreksi ? 'Koreksi' : usulan.jenis.label,
                      if (usulan.provinsi.isNotEmpty) usulan.provinsi,
                      if (namaPengusul != null && namaPengusul!.isNotEmpty)
                        namaPengusul!,
                      tanggal(usulan.diperbaruiPada),
                    ].join(' · '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption(fontSize: 11, height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(status.ikon, size: 14, color: status.warna),
                      const SizedBox(width: 5),
                      Text(
                        status.label.toUpperCase(),
                        style: AppTypography.eyebrow(
                          fontSize: 9.5,
                          color: status.warna,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
