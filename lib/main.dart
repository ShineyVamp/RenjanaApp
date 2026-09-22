import 'package:cloud_firestore/cloud_firestore.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes:
        20 * 1024 * 1024, // batas cache lru 20 mb
  );
  await PreferenceHandler.init();
  PaintingBinding.instance.imageCache.maximumSize = 1500;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 250 * 1024 * 1024;
  await LayananNotifikasi().inisialisasi();
  // kategori
  await KategoriRepository().muat();
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
