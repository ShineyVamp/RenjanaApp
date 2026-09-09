import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dekorasi.dart';
import '../../../../core/constants/app_typography.dart';
import 'package:renjana/features/kontribusi/data/models/usulan_model.dart';
import 'package:renjana/features/kontribusi/data/repositories/usulan_repository.dart';

// Menyandingkan arsip yang sekarang dengan yang diusulkan pengoreksi.
//
// Yang berubah ditampilkan lebih dulu dan diberi warna, sedangkan yang tidak
// disentuh disembunyikan agar admin tidak perlu memindai ulang seluruh isi.
class PerbandinganKoreksi extends StatefulWidget {
  final Usulan usulan;
  final UsulanRepository repository;

  const PerbandinganKoreksi({
    super.key,
    required this.usulan,
    required this.repository,
  });

  @override
  State<PerbandinganKoreksi> createState() => _PerbandinganKoreksiState();
}

class _PerbandinganKoreksiState extends State<PerbandinganKoreksi> {
  List<BedaKoreksi> _beda = const [];
  bool _isLoading = true;
  bool _tampilkanSemua = false;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    final beda = await widget.repository.bandingkanKoreksi(widget.usulan);
    if (!mounted) return;
    setState(() {
      _beda = beda;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_beda.isEmpty) {
      return _buildKeterangan(
        'Arsip yang dikoreksi sudah tidak ada, jadi perbandingannya tidak '
        'bisa ditampilkan.',
        AppColors.error,
      );
    }

    final berubah = _beda.where((b) => b.berubah).toList();
    if (berubah.isEmpty) {
      return _buildKeterangan(
        'Pengusul tidak mengubah satu pun isi arsip ini.',
        AppColors.warning,
      );
    }

    final tampil = _tampilkanSemua ? _beda : berubah;
    final tersembunyi = _beda.length - berubah.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.compare_arrows_rounded,
              size: 18,
              color: AppColors.warning,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${berubah.length} BAGIAN DIUBAH',
                style: AppTypography.eyebrow(color: AppColors.warning),
              ),
            ),
            if (tersembunyi > 0)
              GestureDetector(
                onTap: () => setState(() => _tampilkanSemua = !_tampilkanSemua),
                behavior: HitTestBehavior.opaque,
                child: Text(
                  _tampilkanSemua
                      ? 'Sembunyikan'
                      : 'Lihat $tersembunyi lainnya',
                  style: AppTypography.labelBold(
                    fontSize: 11.5,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        ...tampil.map(_buildBaris),
      ],
    );
  }

  Widget _buildKeterangan(String pesan, Color warna) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: AppDekorasi.panelCapaian(warna, menonjol: false),
      child: Text(
        pesan,
        style: AppTypography.caption(fontSize: 11.5, height: 1.4),
      ),
    );
  }

  Widget _buildBaris(BedaKoreksi beda) {
    final berubah = beda.berubah;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: AppDekorasi.panel(
        garis: berubah ? AppColors.warning : AppColors.border,
        tebal: berubah ? 1.2 : 1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  beda.label,
                  style: AppTypography.labelBold(fontSize: 12.5),
                ),
              ),
              if (!berubah)
                Text(
                  beda.dibiarkan ? 'DIBIARKAN' : 'TETAP',
                  style: AppTypography.eyebrow(
                    fontSize: 8.5,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _buildSisi('Sekarang', beda.sebelum, coret: berubah),
          if (berubah) ...[
            const SizedBox(height: 8),
            _buildSisi('Diusulkan', beda.sesudah, sorot: true),
          ],
        ],
      ),
    );
  }

  Widget _buildSisi(
    String label,
    String isi, {
    bool coret = false,
    bool sorot = false,
  }) {
    final kosong = isi.trim().isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.eyebrow(
            fontSize: 8.5,
            color: sorot ? AppColors.warning : AppColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          kosong ? '— kosong —' : isi,
          style:
              AppTypography.caption(
                fontSize: 12,
                height: 1.45,
                fontWeight: sorot ? FontWeight.w700 : FontWeight.normal,
                color: kosong
                    ? AppColors.surfaceMuted
                    : (sorot ? AppColors.textPrimary : AppColors.textSecondary),
              ).copyWith(
                decoration: coret && !kosong
                    ? TextDecoration.lineThrough
                    : null,
                decorationColor: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}
