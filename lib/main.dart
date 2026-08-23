import 'package:device_preview/device_preview.dart';
import 'package:device_preview/presets.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:renjana/presentation/splash/splash_page.dart';
import 'package:renjana/services/preference_handler.dart';

import 'core/constants/app_theme.dart';
import 'data/repositories/kategori_repository.dart';

// Dipakai halaman yang perlu memuat ulang datanya setiap kali halaman di
// atasnya ditutup, mis. beranda setelah pengguna membaca sebuah arsip.
final RouteObserver<ModalRoute<void>> pengamatRute =
    RouteObserver<ModalRoute<void>>();

void main() async {
  DevicePreview();
  await initializeDateFormatting('id_ID', null);
  await PreferenceHandler.init();
  // Katalog kategori dibaca lebih dulu karena beranda dan form isi konten
  // sudah membutuhkannya sejak layar pertama.
  await KategoriRepository().muat();
  final c = DevicePreview.controller;
  await c.applyPreset(DevicePresets.iPhone16e);
  await c.setOrientation(Orientation.portrait);
  runApp(const RenjanaApp());
}

class RenjanaApp extends StatelessWidget {
  const RenjanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Renjana',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      navigatorObservers: [pengamatRute],
      home: const SplashPage(),
    );
  }
}
