import 'package:flutter/material.dart';
import 'package:renjana/core/constants/app_colors.dart';

// Kartu disusun beberapa baris ke bawah, kolom berikutnya diakses dengan
// menggeser ke samping. Dipakai rekomendasi kuis dan daftar arsip daerah.
class GridHorizontal extends StatefulWidget {
  final int jumlahItem;
  final Widget Function(int index) builder;
  final int baris;
  final double lebarKartu;
  final double tinggiKartu;
  final double jarakBaris;
  final double jarakKolom;

  const GridHorizontal({
    super.key,
    required this.jumlahItem,
    required this.builder,
    this.baris = 3,
    required this.lebarKartu,
    required this.tinggiKartu,
    this.jarakBaris = 16,
    this.jarakKolom = 20,
  });

  @override
  State<GridHorizontal> createState() => _GridHorizontalState();
}

class _GridHorizontalState extends State<GridHorizontal> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  List<Widget> _buildKolom() {
    final kolom = <Widget>[];
    for (int mulai = 0; mulai < widget.jumlahItem; mulai += widget.baris) {
      final sisa = widget.jumlahItem - mulai;
      final isi = sisa < widget.baris ? sisa : widget.baris;
      final kolomTerakhir = mulai + widget.baris >= widget.jumlahItem;

      kolom.add(
        Padding(
          padding: EdgeInsets.only(
            right: kolomTerakhir ? 0 : widget.jarakKolom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(isi, (i) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: i < isi - 1 ? widget.jarakBaris : 0,
                ),
                child: SizedBox(
                  width: widget.lebarKartu,
                  height: widget.tinggiKartu,
                  child: widget.builder(mulai + i),
                ),
              );
            }),
          ),
        ),
      );
    }
    return kolom;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.jumlahItem == 0) return const SizedBox.shrink();

    // Hitung apakah konten melebihi batas 1 kolom (perlu scroll horizontal atau tidak)
    final bool butuhScroll = widget.jumlahItem > widget.baris;

    return ScrollbarTheme(
      data: const ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(AppColors.primary),
      ),
      child: Scrollbar(
        controller: _scroll,
        thumbVisibility: butuhScroll,
        trackVisibility: butuhScroll,
        scrollbarOrientation: ScrollbarOrientation.bottom,
        thickness: 4,
        child: SingleChildScrollView(
          controller: _scroll,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(bottom: butuhScroll ? 40 : 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildKolom(),
          ),
        ),
      ),
    );
  }
}
