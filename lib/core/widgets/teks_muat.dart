import 'package:flutter/material.dart';

// section widget teks adaptif
class TeksMuat extends StatelessWidget {
  final String teks;
  final TextStyle gaya;
  final int maksBaris;
  final int? ambangKata;
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
