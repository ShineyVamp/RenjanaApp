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

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          controller: _scroll,
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildKolom(),
          ),
        ),
        if (butuhScroll) ...[
          const SizedBox(height: 10),
          _IndikatorScrollHorizontal(controller: _scroll),
        ],
      ],
    );
  }
}

// Indikator posisi gulir horizontal yang diletakkan terpisah di bawah konten,
// sehingga tidak akan pernah menimpa kartu atau menyisakan ruang kosong besar.
class _IndikatorScrollHorizontal extends StatelessWidget {
  final ScrollController controller;

  const _IndikatorScrollHorizontal({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final double totalWidth = constraints.maxWidth;
            double progress = 0.0;
            double thumbWidth = totalWidth * 0.4;

            if (controller.hasClients &&
                controller.position.maxScrollExtent > 0) {
              final maxScroll = controller.position.maxScrollExtent;
              final viewport = controller.position.viewportDimension;
              final currentScroll = controller.position.pixels.clamp(
                0.0,
                maxScroll,
              );
              final contentRatio = viewport / (viewport + maxScroll);
              thumbWidth = (totalWidth * contentRatio).clamp(36.0, totalWidth);
              progress = currentScroll / maxScroll;
            }

            final double maxOffset = totalWidth - thumbWidth;
            final double thumbOffset = (progress * maxOffset).clamp(
              0.0,
              maxOffset,
            );

            return Container(
              width: totalWidth,
              height: 3.5,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: thumbOffset,
                    top: 0,
                    bottom: 0,
                    width: thumbWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
