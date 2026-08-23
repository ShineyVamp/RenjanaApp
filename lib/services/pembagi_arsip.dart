import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../core/constants/app_colors.dart';

// Membagikan sebuah arsip lewat aplikasi lain di perangkat.
//
// Yang dibagikan adalah ringkasan berbentuk teks, bukan tautan, sebab Renjana
// belum punya alamat web yang bisa dibuka orang lain.
Future<void> bagikanArsip(
  BuildContext context, {
  required String judul,
  required String jenis,
  String keterangan = '',
  String kodeTag = '',
  String? provinsi,
}) async {
  final baris = <String>[
    judul,
    if (keterangan.trim().isNotEmpty) '',
    if (keterangan.trim().isNotEmpty) _potong(keterangan.trim()),
    '',
    [
      jenis,
      if (provinsi != null && provinsi.trim().isNotEmpty) provinsi.trim(),
      if (kodeTag.trim().isNotEmpty) kodeTag.trim(),
    ].join(' · '),
    'Dibaca di Renjana — Museum Indonesia Dalam Genggaman',
  ];

  final messenger = ScaffoldMessenger.of(context);

  try {
    final hasil = await SharePlus.instance.share(
      ShareParams(text: baris.join('\n'), subject: judul),
    );
    if (hasil.status == ShareResultStatus.unavailable) {
      _beriTahu(messenger, 'Tidak ada aplikasi yang bisa membagikan ini.');
    }
  } catch (_) {
    _beriTahu(messenger, 'Gagal membagikan arsip ini.');
  }
}

// Keterangan panjang dipotong supaya yang dibagikan tetap ringkas dan tidak
// memindahkan seluruh isi arsip keluar aplikasi.
String _potong(String teks, {int batas = 220}) {
  if (teks.length <= batas) return teks;

  final potongan = teks.substring(0, batas);
  final spasi = potongan.lastIndexOf(' ');
  return '${spasi > 0 ? potongan.substring(0, spasi) : potongan}…';
}

void _beriTahu(ScaffoldMessengerState messenger, String pesan) {
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      content: Text(pesan),
      duration: const Duration(milliseconds: 1800),
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.primaryDark,
    ),
  );
}
