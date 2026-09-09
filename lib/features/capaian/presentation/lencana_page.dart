import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dekorasi.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/app_bar_halaman.dart';
import '../data/models/lencana_model.dart';
import 'package:renjana/features/capaian/data/repositories/lencana_repository.dart';
import 'widgets/keping_lencana.dart';

// Pajangan lencana. Yang belum terbuka tetap ditampilkan sebagai bingkai
// kosong beserta kemajuannya, supaya syaratnya terlihat jelas.
class LencanaPage extends StatefulWidget {
  const LencanaPage({super.key});

  @override
  State<LencanaPage> createState() => _LencanaPageState();
}

class _LencanaPageState extends State<LencanaPage> {
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
  }

  // Menyemat dibatasi tiga; bila penuh, pengguna diberi tahu daripada
  // sematannya diam-diam tidak berubah.
  Future<void> _ubahSematan(StatusLencana status) async {
    final berhasil = await _repository.setSematan(
      status.lencana.kode,
      !status.disematkan,
    );
    if (!mounted) return;

    if (!berhasil) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Sematan sudah penuh. Lepas salah satu lebih dulu.'),
          duration: Duration(milliseconds: 1600),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primaryDark,
        ),
      );
      return;
    }
    await _muatData();
  }

  @override
  Widget build(BuildContext context) {
    final terbuka = _status.where((s) => s.terbuka).length;
    final gelar = gelarDariLencana(terbuka);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarHalaman(judul: 'Lencana'),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _muatData,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                    children: [
                      _buildRingkasan(terbuka, gelar),
                      const SizedBox(height: 22),
                      ..._status.map(_buildBaris),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  // Gelar dan jumlah lencana, satu-satunya bagian yang diberi aksen emas penuh.
  Widget _buildRingkasan(int terbuka, GelarPengguna gelar) {
    GelarPengguna? berikutnya;
    for (final g in gelarList) {
      if (g.ambang > terbuka) {
        berikutnya = g;
        break;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: AppDekorasi.panelCapaian(AppColors.gold),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('GELAR SAAT INI', style: AppTypography.eyebrow()),
          const SizedBox(height: 4),
          Text(
            gelar.nama,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 30,
              color: AppColors.textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.military_tech_rounded,
                size: 16,
                color: AppColors.gold,
              ),
              const SizedBox(width: 6),
              Text(
                '$terbuka dari ${_status.length} lencana terkumpul',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (berikutnya != null) ...[
            const SizedBox(height: 4),
            Text(
              '${berikutnya.ambang - terbuka} lencana lagi menuju '
              '${berikutnya.nama}',
              style: AppTypography.bodySmall().copyWith(fontSize: 11.5),
            ),
          ],
          if (terbuka > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Sematkan hingga ${LencanaRepository.batasSematan} lencana '
              'lewat ikon pin, untuk dipajang di halaman profil.',
              style: AppTypography.bodySmall().copyWith(
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBaris(StatusLencana status) {
    final terbuka = status.terbuka;
    final warna = terbuka ? AppColors.gold : AppColors.border;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 13, 16, 13),
      decoration: AppDekorasi.panelCapaian(warna, menonjol: terbuka),
      child: Row(
        children: [
          KepingLencana(status: status, ukuran: 44),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        status.lencana.nama,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: terbuka
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    if (status.baru) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        color: AppColors.gold,
                        child: Text(
                          'BARU',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  status.lencana.keterangan,
                  style: AppTypography.bodySmall().copyWith(fontSize: 11),
                ),
                if (!terbuka && status.target > 0) ...[
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRect(
                          child: LinearProgressIndicator(
                            value: status.rasio,
                            minHeight: 3,
                            backgroundColor: AppColors.border,
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.perunggu,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${status.tercapai}/${status.target}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (terbuka) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _ubahSematan(status),
              icon: Icon(
                status.disematkan
                    ? Icons.push_pin_rounded
                    : Icons.push_pin_outlined,
                size: 19,
              ),
              color: status.disematkan
                  ? AppColors.gold
                  : AppColors.surfaceMuted,
              tooltip: status.disematkan
                  ? 'Lepas dari profil'
                  : 'Sematkan di profil',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ],
      ),
    );
  }
}
