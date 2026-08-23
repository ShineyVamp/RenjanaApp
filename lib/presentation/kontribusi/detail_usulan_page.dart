import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dekorasi.dart';
import '../../core/constants/app_typography.dart';
import '../../core/extensions/navigation.dart';
import '../../core/widgets/app_bar_halaman.dart';
import '../../data/models/usulan_model.dart';
import '../../data/repositories/budaya_repository.dart';
import '../../data/repositories/sejarah_repository.dart';
import '../../data/repositories/usulan_repository.dart';
import '../detail/detail_budaya_page.dart';
import '../detail/detail_sejarah_page.dart';
import 'form_usulan_page.dart';
import 'widgets/kartu_usulan.dart';
import 'widgets/pratinjau_usulan.dart';

// Satu usulan milik pengguna: statusnya, catatan admin bila ada, dan seluruh
// isi yang diajukan.
class DetailUsulanPage extends StatefulWidget {
  final Usulan usulan;

  const DetailUsulanPage({super.key, required this.usulan});

  @override
  State<DetailUsulanPage> createState() => _DetailUsulanPageState();
}

class _DetailUsulanPageState extends State<DetailUsulanPage> {
  final UsulanRepository _repository = UsulanRepository();
  final SejarahRepository _sejarahRepository = SejarahRepository();
  final BudayaRepository _budayaRepository = BudayaRepository();

  late Usulan _usulan;
  bool _berubah = false;

  @override
  void initState() {
    super.initState();
    _usulan = widget.usulan;
  }

  Future<void> _muatUlang() async {
    final id = _usulan.id;
    if (id == null) return;

    final terbaru = await _repository.ambil(id);
    if (!mounted || terbaru == null) return;
    setState(() {
      _usulan = terbaru;
      _berubah = true;
    });
  }

  Future<void> _perbaiki() async {
    final hasil = await context.push(FormUsulanPage(usulanAwal: _usulan));
    if (!mounted || hasil != true) return;
    await _muatUlang();
  }

  // Membuka arsip yang terbit dari usulan ini. Tema kuis tidak punya halaman
  // detail, jadi hanya sejarah dan budaya yang bisa dibuka.
  Future<void> _bukaArsip() async {
    final kodeTag = _usulan.koreksi
        ? _usulan.targetKodeTag
        : _usulan.kodeTagHasil;
    if (kodeTag.trim().isEmpty) return;

    Widget? tujuan;
    switch (_usulan.jenis) {
      case JenisUsulan.sejarah:
        final arsip = await _sejarahRepository.getSejarahByKodeTag(kodeTag);
        if (arsip != null) tujuan = DetailSejarahPage(sejarah: arsip);
      case JenisUsulan.budaya:
        final arsip = await _budayaRepository.getBudayaByKodeTag(kodeTag);
        if (arsip != null) tujuan = DetailBudayaPage(budaya: arsip);
      case JenisUsulan.kuis:
        tujuan = null;
    }
    if (!mounted) return;

    if (tujuan == null) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _usulan.jenis == JenisUsulan.kuis
                ? 'Tema kuis tidak punya halaman detail. Carilah di halaman '
                      'Kuis pada kategorinya.'
                : 'Arsip $kodeTag sudah tidak ada.',
          ),
          duration: const Duration(milliseconds: 2400),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primaryDark,
        ),
      );
      return;
    }

    await context.push(tujuan);
  }

  Future<void> _batalkan() async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text('Tarik usulan ini?', style: AppTypography.headingSmall()),
        content: Text(
          'Usulan akan dihapus dan tidak lagi ditinjau admin. Isinya tidak '
          'bisa dikembalikan.',
          style: AppTypography.bodyMedium(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(
              'Batal',
              style: AppTypography.labelBold(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(
              'Tarik',
              style: AppTypography.labelBold(fontSize: 13, color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (setuju != true || !mounted) return;

    final id = _usulan.id;
    if (id == null) return;
    await _repository.batalkan(id);
    if (!mounted) return;
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (sudah, _) {
        if (sudah) return;
        context.pop(_berubah);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBarHalaman(
          judul: _usulan.jenis.label,
          onKembali: () => context.pop(_berubah),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
              children: [
                _buildStatus(),
                const SizedBox(height: 16),
                if (_usulan.catatanAdmin.trim().isNotEmpty) ...[
                  _buildCatatan(),
                  const SizedBox(height: 16),
                ],
                PratinjauUsulan(usulan: _usulan),
                const SizedBox(height: 12),
                ..._buildTindakan(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatus() {
    final status = _usulan.status;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: AppDekorasi.panelCapaian(status.warna),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(status.ikon, size: 18, color: status.warna),
              const SizedBox(width: 8),
              Text('STATUS USULAN', style: AppTypography.eyebrow()),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            status.label,
            style: AppTypography.angka(
              color: AppColors.textPrimary,
            ).copyWith(height: 1.1),
          ),
          const SizedBox(height: 4),
          Text(
            _keteranganStatus(status),
            style: AppTypography.caption(fontSize: 11.5, height: 1.4),
          ),
          const SizedBox(height: 8),
          Text(
            'Diajukan ${KartuUsulan.tanggal(_usulan.dibuatPada)}'
            '${_usulan.diperbaruiPada != _usulan.dibuatPada ? ' · diperbarui ${KartuUsulan.tanggal(_usulan.diperbaruiPada)}' : ''}',
            style: AppTypography.caption(fontSize: 10.5),
          ),
        ],
      ),
    );
  }

  String _keteranganStatus(StatusUsulan status) {
    switch (status) {
      case StatusUsulan.menunggu:
        return 'Usulan sudah masuk antrean tinjauan admin.';
      case StatusUsulan.revisi:
        return 'Admin meminta beberapa hal diperbaiki sebelum bisa terbit.';
      case StatusUsulan.disetujui:
        return _usulan.kodeTagHasil.isEmpty
            ? 'Usulan diterima dan sudah diterbitkan.'
            : 'Sudah terbit sebagai arsip ${_usulan.kodeTagHasil}.';
      case StatusUsulan.ditolak:
        return 'Usulan tidak diterbitkan. Alasannya ada di catatan admin.';
    }
  }

  Widget _buildCatatan() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppDekorasi.panel(garis: AppColors.border),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CATATAN ADMIN', style: AppTypography.eyebrow()),
          const SizedBox(height: 6),
          Text(
            _usulan.catatanAdmin,
            style: AppTypography.caption(
              fontSize: 12.5,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTindakan() {
    // Arsip hasil usulan bisa dibuka begitu terbit, termasuk pada koreksi yang
    // menunjuk arsip yang memang sudah ada.
    if (_usulan.status == StatusUsulan.disetujui) {
      return [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: AppDekorasi.radiusKecil,
              ),
            ),
            onPressed: _bukaArsip,
            icon: const Icon(
              Icons.menu_book_rounded,
              size: 18,
              color: Colors.white,
            ),
            label: Text(
              'Lihat Arsip yang Terbit',
              style: AppTypography.buttonText().copyWith(fontSize: 13.5),
            ),
          ),
        ),
      ];
    }

    if (!_usulan.status.bisaDisunting) return const [];

    return [
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: AppDekorasi.radiusKecil,
            ),
          ),
          onPressed: _perbaiki,
          icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.white),
          label: Text(
            _usulan.status == StatusUsulan.revisi
                ? 'Perbaiki & Kirim Ulang'
                : 'Sunting Usulan',
            style: AppTypography.buttonText().copyWith(fontSize: 13.5),
          ),
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        width: double.infinity,
        child: TextButton.icon(
          onPressed: _batalkan,
          icon: const Icon(
            Icons.delete_outline_rounded,
            size: 18,
            color: AppColors.error,
          ),
          label: Text(
            'Tarik Usulan',
            style: AppTypography.labelBold(
              fontSize: 13,
              color: AppColors.error,
            ),
          ),
        ),
      ),
    ];
  }
}
