import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dekorasi.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/repositories/runtun_repository.dart';

// Runtun kunjungan dan misi kecil hari ini. Memuat datanya sendiri agar
// beranda tidak perlu ikut menunggu.
class MisiHarianCard extends StatefulWidget {
  const MisiHarianCard({super.key});

  @override
  State<MisiHarianCard> createState() => _MisiHarianCardState();
}

class _MisiHarianCardState extends State<MisiHarianCard> {
  final RuntunRepository _repository = RuntunRepository();

  RingkasanRuntun _runtun = const RingkasanRuntun();
  List<MisiHarian> _misi = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    final misi = await _repository.misiHariIni();
    final runtun = await _repository.ringkasan();
    if (!mounted) return;
    setState(() {
      _misi = misi;
      _runtun = runtun;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox(height: 8);

    final selesai = _misi.where((m) => m.selesai).length;
    final tuntas = selesai == _misi.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 6),
      decoration: AppDekorasi.panelCapaian(
        tuntas ? AppColors.gold : AppColors.borderPrimary,
        menonjol: tuntas,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKepala(selesai, tuntas),
          const SizedBox(height: 14),
          ..._misi.map(_buildBarisMisi),
        ],
      ),
    );
  }

  // Angka runtun dibuat besar sebagai satu-satunya penekanan pada kartu ini.
  Widget _buildKepala(int selesai, bool tuntas) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('RUNTUN HARIAN', style: AppTypography.eyebrow()),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${_runtun.berjalan}',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 34,
                    color: tuntas ? AppColors.gold : AppColors.textPrimary,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _runtun.berjalan == 1 ? 'hari' : 'hari berturut',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$selesai/${_misi.length}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: tuntas ? AppColors.gold : AppColors.textPrimary,
              ),
            ),
            Text(
              'misi hari ini',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                color: AppColors.textSecondary,
              ),
            ),
            if (_runtun.terpanjang > _runtun.berjalan) ...[
              const SizedBox(height: 6),
              Text(
                'Terpanjang ${_runtun.terpanjang} hari',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildBarisMisi(MisiHarian misi) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: AppDekorasi.barisAtas,
      child: Row(
        children: [
          Icon(
            misi.selesai
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 18,
            color: misi.selesai ? AppColors.gold : AppColors.surfaceMuted,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  misi.nama,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: misi.selesai
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  misi.keterangan,
                  style: AppTypography.bodySmall().copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
