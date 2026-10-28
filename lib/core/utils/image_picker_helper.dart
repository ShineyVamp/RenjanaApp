import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/app_colors.dart';

// Bantuan izin galeri (Android Photo Picker tidak memerlukan izin penyimpanan khusus)
Future<bool> mintaIzinGaleri(BuildContext context) async {
  return true;
}

// Pilih dan kompresi gambar menggunakan Android Photo Picker
Future<String?> pilihGambarDariGaleri(BuildContext context) async {
  try {
    final gambar = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 80,
    );
    return gambar?.path;
  } catch (_) {
    if (context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Gagal memilih gambar dari galeri.'),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
    return null;
  }
}
