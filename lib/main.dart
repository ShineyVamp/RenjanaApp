import 'package:device_preview/device_preview.dart';
import 'package:device_preview/presets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:renjana/core/storage/preference_handler.dart';
import 'package:renjana/features/splash/presentation/splash_page.dart';
import 'package:renjana/firebase_options.dart';

import 'app/routes/app_routes.dart';
import 'core/constants/app_theme.dart';
import 'core/services/notification_service.dart';
import 'features/budaya/data/repositories/kategori_repository.dart';

export 'app/routes/app_routes.dart';

void main() async {
  DevicePreview();
  await initializeDateFormatting('id_ID', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await PreferenceHandler.init();
  await LayananNotifikasi().inisialisasi();
  // Katalog kategori dibaca lebih dulu karena beranda dan form isi konten
  // sudah membutuhkannya sejak layar pertama.
  await KategoriRepository().muat();
  final c = DevicePreview.controller;
  await c.applyPreset(DevicePresets.pixel10);
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
