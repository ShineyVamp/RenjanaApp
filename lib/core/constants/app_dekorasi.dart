import 'package:flutter/material.dart';

import 'app_colors.dart';

// section dekorasi aplikasi
class AppDekorasi {
  AppDekorasi._();

  // section radius sudut
  static const double lengkungKartu = 12;
  static const double lengkungKecil = 8;

  static BorderRadius get radiusKartu => BorderRadius.circular(lengkungKartu);
  static BorderRadius get radiusKecil => BorderRadius.circular(lengkungKecil);

  // section panel dan kartu
  static BoxDecoration panel({
    Color? garis,
    double tebal = 1,
    double? lengkung,
  }) => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(lengkung ?? lengkungKartu),
    border: Border.all(color: garis ?? AppColors.borderPrimary, width: tebal),
  );

  static BoxDecoration panelCapaian(Color warna, {bool menonjol = true}) =>
      BoxDecoration(
        color: AppColors.surface,
        borderRadius: radiusKartu,
        border: Border.all(color: warna, width: menonjol ? 1.2 : 1),
      );

  static BoxDecoration kontrolPeta() => BoxDecoration(
    color: AppColors.background.withValues(alpha: 0.92),
    borderRadius: radiusKecil,
    border: Border.all(color: AppColors.border),
  );

  // section batas dan pemisah
  static const BoxDecoration barisDaftar = BoxDecoration(
    border: Border(bottom: BorderSide(color: AppColors.border)),
  );

  static const BoxDecoration barisAtas = BoxDecoration(
    border: Border(top: BorderSide(color: AppColors.border)),
  );
}
