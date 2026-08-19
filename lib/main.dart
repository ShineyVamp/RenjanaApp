import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:renjana/presentation/main/main_page.dart';

import 'core/constants/app_theme.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  // DevicePreview.enable();
  // final c = DevicePreview.controller;
  // await c.applyPreset(DevicePresets.iPhone16e);
  // await c.setOrientation(Orientation.portrait);

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
      home: const MainPage(),
    );
  }
}
