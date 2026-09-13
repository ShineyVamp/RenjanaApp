import 'package:flutter/material.dart';

import '../../core/extensions/navigation.dart';
import '../../features/budaya/presentation/detail_budaya_page.dart';
import '../../features/capaian/data/repositories/riwayat_repository.dart';
import '../../features/jelajah/data/models/hasil_jelajah_model.dart';
import '../../features/sejarah/presentation/detail_sejarah_page.dart';
import '../../features/wilayah/presentation/detail_provinsi_page.dart';
import '../../features/wilayah/presentation/detail_pulau_page.dart';

// section navigasi hasil arsip
Future<void> bukaHasilJelajah(BuildContext context, HasilJelajah item) async {
  if (item.jenis == JenisArsip.sejarah && item.sejarah != null) {
    RiwayatRepository().catatDibuka('sejarah', item.sejarah!.kodeTag);
  } else if (item.jenis == JenisArsip.budaya && item.budaya != null) {
    RiwayatRepository().catatDibuka('budaya', item.budaya!.kodeTag);
  }

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
