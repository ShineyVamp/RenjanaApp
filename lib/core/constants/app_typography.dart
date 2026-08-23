import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  // DM Serif Display: judul besar dan branding
  static TextStyle headingLarge({Color color = AppColors.textPrimary}) =>
      GoogleFonts.dmSerifDisplay(
        fontSize: 42,
        fontWeight: FontWeight.bold,
        color: color,
      );

  static TextStyle headingMedium({Color color = AppColors.textPrimary}) =>
      GoogleFonts.dmSerifDisplay(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: color,
      );

  static TextStyle headingSmall({Color color = AppColors.textPrimary}) =>
      GoogleFonts.dmSerifDisplay(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: color,
      );

  static TextStyle brandTitle({Color color = AppColors.textPrimary}) =>
      GoogleFonts.dmSerifDisplay(
        fontSize: 28,
        fontWeight: FontWeight.normal,
        color: color,
      );

  // Playfair Display: judul section halaman detail
  static TextStyle editorialHeading({Color color = AppColors.textPrimary}) =>
      GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: color,
      );

  static TextStyle editorialSubheading({
    Color color = AppColors.textSecondary,
  }) => GoogleFonts.playfairDisplay(fontSize: 14, height: 1.4, color: color);

  // Plus Jakarta Sans: teks isi, tombol, label, dan keterangan
  static TextStyle bodyLarge({Color color = AppColors.textSecondary}) =>
      GoogleFonts.plusJakartaSans(fontSize: 16, height: 1.5, color: color);

  static TextStyle bodyMedium({Color color = AppColors.textSecondary}) =>
      GoogleFonts.plusJakartaSans(fontSize: 14.5, height: 1.6, color: color);

  static TextStyle bodySmall({Color color = AppColors.textSecondary}) =>
      GoogleFonts.plusJakartaSans(fontSize: 12, color: color);

  static TextStyle buttonText({Color color = Colors.white}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: color,
      );

  static TextStyle labelBold({
    double fontSize = 14,
    Color color = AppColors.textPrimary,
  }) => GoogleFonts.plusJakartaSans(
    fontSize: fontSize,
    fontWeight: FontWeight.bold,
    color: color,
  );

  static TextStyle tag({Color color = Colors.white}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: color,
      );

  // Label kecil huruf kapital di atas sebuah judul, mis. "PENUNTASAN".
  static TextStyle eyebrow({
    double fontSize = 10,
    Color color = AppColors.primary,
    double letterSpacing = 1.2,
  }) => GoogleFonts.plusJakartaSans(
    fontSize: fontSize,
    fontWeight: FontWeight.w800,
    letterSpacing: letterSpacing,
    color: color,
  );

  // Keterangan pendek di dalam kartu dan baris daftar.
  static TextStyle caption({
    double fontSize = 11.5,
    Color color = AppColors.textSecondary,
    FontWeight fontWeight = FontWeight.normal,
    double? height,
  }) => GoogleFonts.plusJakartaSans(
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: height,
    color: color,
  );

  // Angka besar sebagai penekanan utama sebuah kartu.
  static TextStyle angka({
    double fontSize = 24,
    Color color = AppColors.primary,
  }) => GoogleFonts.dmSerifDisplay(fontSize: fontSize, height: 1, color: color);
}
