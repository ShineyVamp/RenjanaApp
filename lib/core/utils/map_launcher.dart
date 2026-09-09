import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_colors.dart';

// Membuka lokasi sebuah destinasi di aplikasi peta yang terpasang.
//
// Arsip tidak menyimpan koordinat, hanya nama tempat dan provinsi, jadi yang
// dikirim adalah kata kunci pencarian. Hasilnya lebih tepat daripada titik
// tengah provinsi, dan tetap benar meski lokasinya berpindah.
Future<void> bukaLokasiDiPeta(
  BuildContext context, {
  required String namaTempat,
  String? provinsi,
}) async {
  final kunci = [
    namaTempat.trim(),
    if (provinsi != null && provinsi.trim().isNotEmpty) provinsi.trim(),
    'Indonesia',
  ].join(', ');

  final messenger = ScaffoldMessenger.of(context);

  // geo: dibuka oleh aplikasi peta apa pun yang terpasang. Bila tidak ada yang
  // menanganinya, dicoba lewat peramban.
  final tujuan = <Uri>[
    Uri.parse('geo:0,0?q=${Uri.encodeComponent(kunci)}'),
    Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=${Uri.encodeComponent(kunci)}',
    ),
  ];

  for (final uri in tujuan) {
    try {
      final berhasil = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (berhasil) return;
    } catch (_) {}
  }

  messenger.clearSnackBars();
  messenger.showSnackBar(
    const SnackBar(
      content: Text('Tidak ada aplikasi peta yang bisa membuka lokasi ini.'),
      backgroundColor: AppColors.primaryDark,
    ),
  );
}
