import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dekorasi.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/extensions/navigation.dart';
import '../../../core/widgets/app_bar_halaman.dart';
import '../../../core/widgets/pesan_kosong.dart';
import 'package:renjana/features/kontribusi/data/models/usulan_model.dart';
import 'package:renjana/features/kontribusi/data/repositories/usulan_repository.dart';
import 'detail_usulan_page.dart';
import 'form_usulan_page.dart';
import 'widgets/kartu_usulan.dart';

// Daftar usulan milik pengguna beserta statusnya, dan pintu masuk untuk
// mengajukan usulan baru.
class KontribusiPage extends StatefulWidget {
  const KontribusiPage({super.key});

  @override
  State<KontribusiPage> createState() => _KontribusiPageState();
}

class _KontribusiPageState extends State<KontribusiPage> {
  final UsulanRepository _repository = UsulanRepository();

  static const int _ukuranHalaman = 20;

  List<Usulan> _usulan = const [];
  int _total = 0;
  bool _isLoading = true;
  bool _memuatLagi = false;

  bool get _adaLagi => _usulan.length < _total;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    final daftar = await _repository.milikSaya(batas: _ukuranHalaman);
    final total = await _repository.jumlahMilikSaya();
    if (!mounted) return;
    setState(() {
      _usulan = daftar;
      _total = total;
      _isLoading = false;
    });
  }

  Future<void> _muatLagi() async {
    if (_memuatLagi || !_adaLagi) return;
    setState(() => _memuatLagi = true);

    final tambahan = await _repository.milikSaya(
      batas: _ukuranHalaman,
      lewati: _usulan.length,
    );
    if (!mounted) return;
    setState(() {
      _usulan = [..._usulan, ...tambahan];
      _memuatLagi = false;
    });
  }

  Future<void> _ajukan() async {
    final hasil = await context.push(const FormUsulanPage());
    if (!mounted || hasil != true) return;
    await _muatData();
  }

  Future<void> _buka(Usulan usulan) async {
    final hasil = await context.push(DetailUsulanPage(usulan: usulan));
    if (!mounted || hasil != true) return;
    await _muatData();
  }

  @override
  Widget build(BuildContext context) {
    final menunggu = _usulan
        .where((u) => u.status == StatusUsulan.menunggu)
        .length;
    final perluDiperbaiki = _usulan
        .where((u) => u.status == StatusUsulan.revisi)
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppBarHalaman(judul: 'Kontribusi Saya'),
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
                      _buildAjakan(menunggu, perluDiperbaiki),
                      const SizedBox(height: 18),

                      if (_usulan.isEmpty)
                        const PesanKosong(
                          pesan:
                              'Belum ada usulan. Arsip yang Anda usulkan akan '
                              'muncul di sini beserta keputusan admin atasnya.',
                          ikon: Icons.volunteer_activism_outlined,
                        )
                      else ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            '${_usulan.length} DARI $_total USULAN',
                            style: AppTypography.eyebrow(fontSize: 9.5),
                          ),
                        ),
                        ..._usulan.map(
                          (u) => KartuUsulan(usulan: u, onTap: () => _buka(u)),
                        ),
                        if (_adaLagi) _buildTombolMuatLagi(),
                      ],
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  // Ajakan mengusulkan, sekaligus penanda bila ada yang perlu ditindaklanjuti.
  Widget _buildAjakan(int menunggu, int perluDiperbaiki) {
    final perluTindakan = perluDiperbaiki > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: AppDekorasi.panelCapaian(
        perluTindakan ? AppColors.warning : AppColors.borderPrimary,
        menonjol: perluTindakan,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TURUT MELESTARIKAN', style: AppTypography.eyebrow()),
          const SizedBox(height: 4),
          Text(
            perluTindakan
                ? '$perluDiperbaiki usulan perlu diperbaiki'
                : 'Usulkan arsip daerah Anda',
            style: AppTypography.angka(
              color: AppColors.textPrimary,
            ).copyWith(fontSize: 22, height: 1.15),
          ),
          const SizedBox(height: 4),
          Text(
            perluTindakan
                ? 'Admin sudah memberi catatan. Buka usulannya untuk melihat '
                      'apa yang perlu diubah.'
                : 'Arsip yang Anda kirim akan ditinjau admin sebelum terbit, '
                      'dan namanya tercantum sebagai kontributor.',
            style: AppTypography.caption(fontSize: 11.5, height: 1.4),
          ),
          if (menunggu > 0) ...[
            const SizedBox(height: 6),
            Text(
              '$menunggu usulan sedang menunggu tinjauan',
              style: AppTypography.caption(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.perunggu,
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: AppDekorasi.radiusKecil,
                ),
              ),
              onPressed: _ajukan,
              icon: const Icon(
                Icons.add_rounded,
                size: 18,
                color: Colors.white,
              ),
              label: Text(
                'Ajukan Usulan',
                style: AppTypography.buttonText().copyWith(fontSize: 13.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTombolMuatLagi() {
    final sisa = _total - _usulan.length;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: AppDekorasi.radiusKecil,
            ),
          ),
          onPressed: _memuatLagi ? null : _muatLagi,
          child: Text(
            _memuatLagi ? 'Memuat…' : 'Muat $_ukuranHalaman lagi · sisa $sisa',
            style: AppTypography.labelBold(
              fontSize: 12.5,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
