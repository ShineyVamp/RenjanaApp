import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  // DM Serif Display Styles (for headings & branding)
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

  // Playfair Display Styles (buat editorial/detail section titles)
  static TextStyle editorialHeading({Color color = AppColors.textPrimary}) =>
      GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: color,
      );

  static TextStyle editorialSubheading({
    Color color = AppColors.textSecondary,
  }) => GoogleFonts.playfairDisplay(fontSize: 14, height: 1.4, color: color);

  // Plus Jakarta Sans Styles (buat UI, body, buttons, dan captions)
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
}
