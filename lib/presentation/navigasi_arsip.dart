import 'package:flutter/material.dart';

import '../core/extensions/navigation.dart';
import '../data/models/hasil_jelajah_model.dart';
import 'detail/detail_budaya_page.dart';
import 'detail/detail_sejarah_page.dart';
import 'wilayah/detail_provinsi_page.dart';
import 'wilayah/detail_pulau_page.dart';

// Pembuka halaman tujuan untuk satu baris hasil, dipakai Jelajah maupun
// halaman wilayah.
Future<void> bukaHasilJelajah(BuildContext context, HasilJelajah item) async {
  final Widget? tujuan = switch (item.jenis) {
    JenisArsip.sejarah =>
      item.sejarah == null ? null : DetailSejarahPage(sejarah: item.sejarah!),
    JenisArsip.budaya =>
      item.budaya == null ? null : DetailBudayaPage(budaya: item.budaya!),
    JenisArsip.pulau =>
      item.pulau == null ? null : DetailPulauPage(pulau: item.pulau!),
    JenisArsip.provinsi =>
      item.wilayah == null ? null : DetailProvinsiPage(provinsi: item.wilayah!),
  };

  if (tujuan == null) return;
  await context.push(tujuan);
}
