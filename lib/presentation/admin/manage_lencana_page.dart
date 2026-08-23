import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dekorasi.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/app_bar_halaman.dart';
import '../../core/widgets/keping_lencana.dart';
import '../../data/repositories/lencana_repository.dart';
import '../../services/pemilih_gambar.dart';

// Pengelolaan logo lencana. Syarat dan nama lencana ditetapkan di katalog
// kode; yang bisa diatur dari sini hanya lambangnya.
class AdminManageLencanaPage extends StatefulWidget {
  const AdminManageLencanaPage({super.key});

  @override
  State<AdminManageLencanaPage> createState() => _AdminManageLencanaPageState();
}

class _AdminManageLencanaPageState extends State<AdminManageLencanaPage> {
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

  Future<void> _gantiLogo(StatusLencana status) async {
    final path = await pilihGambarDariGaleri(context);
    if (path == null || !mounted) return;

    await _repository.setLogo(status.lencana.kode, path);
    if (!mounted) return;
    await _muatData();
    _beriTahu('Logo ${status.lencana.nama} diperbarui');
  }

  Future<void> _lepasLogo(StatusLencana status) async {
    await _repository.setLogo(status.lencana.kode, null);
    if (!mounted) return;
    await _muatData();
    _beriTahu('Logo ${status.lencana.nama} kembali ke bawaan');
  }

  void _beriTahu(String pesan) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(pesan),
        duration: const Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final berlogo = _status.where((s) => s.gambar.isNotEmpty).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppBarHalaman(judul: 'Logo Lencana'),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: AppDekorasi.panel(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LOGO TERPASANG',
                            style: AppTypography.eyebrow(),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$berlogo dari ${_status.length} lencana',
                            style: AppTypography.labelBold(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lencana tanpa logo memakai ikon bawaan. Nama dan '
                            'syaratnya diatur di berkas katalog, bukan di sini.',
                            style: AppTypography.caption(
                              fontSize: 11,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._status.map(_buildBaris),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBaris(StatusLencana status) {
    final adaLogo = status.gambar.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: AppDekorasi.panel(garis: AppColors.border),
      child: Row(
        children: [
          KepingLencana(status: status, ukuran: 44),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.lencana.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelBold(fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  status.lencana.kode,
                  style: AppTypography.caption(fontSize: 10.5),
                ),
              ],
            ),
          ),
          if (adaLogo)
            IconButton(
              onPressed: () => _lepasLogo(status),
              icon: const Icon(Icons.restart_alt_rounded, size: 19),
              color: AppColors.error,
              tooltip: 'Kembalikan ke ikon bawaan',
              visualDensity: VisualDensity.compact,
            ),
          IconButton(
            onPressed: () => _gantiLogo(status),
            icon: const Icon(Icons.image_outlined, size: 19),
            color: AppColors.primary,
            tooltip: adaLogo ? 'Ganti logo' : 'Pilih logo',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
