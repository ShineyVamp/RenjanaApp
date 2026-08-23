import 'package:flutter/material.dart';

// Teks yang ukurannya mengecil sendiri sampai muat dalam lebar yang tersedia
// dan sebanyak-banyaknya [maksBaris]. Dipakai judul kartu yang panjang isinya
// tidak bisa diperkirakan, mis. nama kategori budaya dan nama destinasi.
class TeksMuat extends StatelessWidget {
  final String teks;
  final TextStyle gaya;
  final int maksBaris;

  // Bila diisi, teks pendek dipaksa satu baris dan hanya teks yang katanya
  // lebih banyak dari ini yang boleh memakai [maksBaris].
  final int? ambangKata;

  // Batas bawah pengecilan; di bawah ini teks dipotong dengan elipsis
  // daripada mengecil sampai tak terbaca.
  final double ukuranMinimum;

  final TextAlign perataan;

  const TeksMuat({
    super.key,
    required this.teks,
    required this.gaya,
    this.maksBaris = 2,
    this.ambangKata,
    this.ukuranMinimum = 10,
    this.perataan = TextAlign.start,
  });

  int get _baris {
    final ambang = ambangKata;
    if (ambang == null) return maksBaris;
    final kata = teks.trim().split(RegExp(r'\s+')).where((k) => k.isNotEmpty);
    return kata.length > ambang ? maksBaris : 1;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final lebar = constraints.maxWidth;
        final baris = _baris;
        var ukuran = gaya.fontSize ?? 14;

        // Dicoba dari ukuran asli, mengecil 0,5 poin tiap langkah sampai muat.
        while (ukuran > ukuranMinimum) {
          if (_muat(ukuran, lebar, baris)) break;
          ukuran -= 0.5;
        }

        return Text(
          teks,
          maxLines: baris,
          textAlign: perataan,
          overflow: TextOverflow.ellipsis,
          style: gaya.copyWith(fontSize: ukuran),
        );
      },
    );
  }

  bool _muat(double ukuran, double lebar, int baris) {
    final pengukur = TextPainter(
      text: TextSpan(
        text: teks,
        style: gaya.copyWith(fontSize: ukuran),
      ),
      maxLines: baris,
      textAlign: perataan,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: lebar);
    return !pengukur.didExceedMaxLines;
  }
}
