import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/constants/app_colors.dart';

// Pemilihan gambar dari galeri perangkat beserta permintaan izinnya.
// Dipakai form admin dan halaman profil.

Future<bool> mintaIzinGaleri(BuildContext context) async {
  try {
    // izin foto untuk Android 13+/iOS, storage untuk Android lama
    PermissionStatus status = await Permission.photos.request();
    if (!status.isGranted && !status.isLimited) {
      status = await Permission.storage.request();
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) _tampilkanDialogIzin(context);
      return false;
    }
    return true;
  } catch (_) {
    // platform yang tidak butuh izin (mis. desktop) langsung diloloskan
    return true;
  }
}

// Mengembalikan path gambar terpilih, atau null bila dibatalkan/gagal.
Future<String?> pilihGambarDariGaleri(BuildContext context) async {
  final berizin = await mintaIzinGaleri(context);
  if (!berizin) return null;

  try {
    final gambar = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    return gambar?.path;
  } catch (_) {
    if (context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Gagal membuka galeri. Pastikan izin aplikasi sudah aktif.',
          ),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
    return null;
  }
}

void _tampilkanDialogIzin(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.background,
      title: Text(
        'Izin Akses Galeri Diperlukan',
        style: GoogleFonts.dmSerifDisplay(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      content: Text(
        'Aplikasi membutuhkan izin akses galeri untuk memilih gambar dari '
        'memori perangkat. Silakan aktifkan di Pengaturan.',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: () {
            Navigator.pop(ctx);
            openAppSettings();
          },
          child: const Text(
            'Buka Pengaturan',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
