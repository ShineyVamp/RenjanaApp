import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_colors.dart';

// section peluncur peta
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

  // skema uri peta dan peramban
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
