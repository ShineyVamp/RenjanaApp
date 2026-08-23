import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dekorasi.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/lencana_katalog.dart';
import '../../../core/extensions/navigation.dart';
import '../../../core/widgets/keping_lencana.dart';
import '../../../data/repositories/lencana_repository.dart';
import '../../capaian/lencana_page.dart';

// Gelar dan tiga lencana pilihan di halaman profil. Penyematannya sendiri
// dilakukan di halaman Lencana, supaya panel ini tetap ringkas.
class PanelLencana extends StatefulWidget {
  final VoidCallback? onBerubah;

  const PanelLencana({super.key, this.onBerubah});

  @override
  State<PanelLencana> createState() => _PanelLencanaState();
}

class _PanelLencanaState extends State<PanelLencana> {
  final LencanaRepository _repository = LencanaRepository();

  List<StatusLencana> _status = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    final status = await _repository.evaluasi();
    if (!mounted) return;
    setState(() {
      _status = status;
      _isLoading = false;
    });
    widget.onBerubah?.call();
  }

  // Yang disemat pengguna didahulukan. Bila belum ada yang dipilih, sisanya
  // diambil acak supaya panel tidak kosong tanpa alasan.
  List<StatusLencana> _pilihan(List<StatusLencana> terbuka) {
    final disemat = terbuka.where((s) => s.disematkan).toList();
    if (disemat.length >= LencanaRepository.batasSematan) {
      return disemat.take(LencanaRepository.batasSematan).toList();
    }

    final sisa = terbuka.where((s) => !s.disematkan).toList()
      ..shuffle(Random(terbuka.length));
    return [
      ...disemat,
      ...sisa.take(LencanaRepository.batasSematan - disemat.length),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox(height: 8);

    final terbuka = _status.where((s) => s.terbuka).toList();
    final gelar = gelarDariLencana(terbuka.length);
    final pilihan = _pilihan(terbuka);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppDekorasi.panelCapaian(
        terbuka.isEmpty ? AppColors.border : AppColors.gold,
        menonjol: terbuka.isNotEmpty,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKepala(terbuka.length, gelar),
          const SizedBox(height: 16),
          if (terbuka.isEmpty)
            Text(
              'Belum ada lencana. Bacalah arsip dan kerjakan kuis untuk mulai '
              'mengumpulkannya.',
              style: AppTypography.caption(fontSize: 11.5, height: 1.4),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(LencanaRepository.batasSematan, (i) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: i == LencanaRepository.batasSematan - 1 ? 0 : 10,
                    ),
                    child: i < pilihan.length
                        ? _buildPilihan(pilihan[i])
                        : const SizedBox.shrink(),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildKepala(int terbuka, GelarPengguna gelar) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('GELAR', style: AppTypography.eyebrow()),
              const SizedBox(height: 2),
              Text(
                gelar.nama,
                style: AppTypography.angka(
                  color: AppColors.textPrimary,
                ).copyWith(height: 1.1),
              ),
              const SizedBox(height: 2),
              Text(
                '$terbuka dari ${_status.length} lencana',
                style: AppTypography.caption(fontSize: 11),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () async {
            await context.push(const LencanaPage());
            if (!mounted) return;
            await _muatData();
          },
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Semua',
                style: AppTypography.labelBold(
                  fontSize: 11.5,
                  color: AppColors.primary,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 17,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPilihan(StatusLencana status) {
    return Column(
      children: [
        KepingLencana(status: status),
        const SizedBox(height: 7),
        Text(
          status.lencana.nama,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.caption(
            fontSize: 10,
            height: 1.25,
            fontWeight: status.disematkan ? FontWeight.w800 : FontWeight.w600,
            color: status.disematkan
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
