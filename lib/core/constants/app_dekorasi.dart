import 'package:flutter/material.dart';

import 'app_colors.dart';

// Bentuk kotak yang berulang di banyak halaman. Dikumpulkan di sini supaya
// ketebalan garis dan warnanya seragam.
class AppDekorasi {
  AppDekorasi._();

  // Satu-satunya lengkung untuk kartu di seluruh aplikasi. Halaman detail
  // sejarah dan budaya punya gayanya sendiri dan tidak memakai ini.
  static const double lengkungKartu = 12;

  // Lengkung untuk elemen kecil: chip, kolom isian, dan tombol.
  static const double lengkungKecil = 8;

  static BorderRadius get radiusKartu => BorderRadius.circular(lengkungKartu);

  static BorderRadius get radiusKecil => BorderRadius.circular(lengkungKecil);

  // Kotak putih bergaris tipis, dipakai kartu dan panel biasa.
  static BoxDecoration panel({
    Color? garis,
    double tebal = 1,
    double? lengkung,
  }) => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(lengkung ?? lengkungKartu),
    border: Border.all(color: garis ?? AppColors.borderPrimary, width: tebal),
  );

  // Panel yang menandai capaian; garisnya memakai warna tingkat.
  static BoxDecoration panelCapaian(Color warna, {bool menonjol = true}) =>
      BoxDecoration(
        color: AppColors.surface,
        borderRadius: radiusKartu,
        border: Border.all(color: warna, width: menonjol ? 1.2 : 1),
      );

  // Kotak transparan bergaris, dipakai kontrol yang mengambang di atas peta.
  static BoxDecoration kontrolPeta() => BoxDecoration(
    color: AppColors.background.withValues(alpha: 0.92),
    borderRadius: radiusKecil,
    border: Border.all(color: AppColors.border),
  );

  // Garis pemisah antar baris di dalam sebuah daftar.
  static const BoxDecoration barisDaftar = BoxDecoration(
    border: Border(bottom: BorderSide(color: AppColors.border)),
  );

  // Garis pemisah di atas baris, dipakai daftar tugas dan misi.
  static const BoxDecoration barisAtas = BoxDecoration(
    border: Border(top: BorderSide(color: AppColors.border)),
  );
}
