import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dekorasi.dart';
import '../../../core/constants/app_typography.dart';
import '../data/static/data_wilayah_nusantara.dart';
import '../../../core/extensions/navigation.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/detail_section_block.dart';
import '../../../core/widgets/detail_top_bar.dart';
import '../../../core/widgets/kartu_hasil.dart';
import 'package:renjana/features/bookmark/data/models/bookmark_model.dart';
import 'package:renjana/features/jelajah/data/models/hasil_jelajah_model.dart';
import 'package:renjana/features/bookmark/data/repositories/bookmark_repository.dart';
import 'package:renjana/app/routes/navigasi_arsip.dart';
import 'package:renjana/core/utils/share_helper.dart';
import 'package:renjana/features/wilayah/data/repositories/progres_wilayah_repository.dart';
import 'package:renjana/features/wilayah/data/repositories/wilayah_repository.dart';
import 'arsip_provinsi_page.dart';
import 'penuntasan_provinsi_page.dart';
import 'widgets/kartu_statistik.dart';

class DetailProvinsiPage extends StatefulWidget {
  final Provinsi provinsi;

  const DetailProvinsiPage({super.key, required this.provinsi});

  @override
  State<DetailProvinsiPage> createState() => _DetailProvinsiPageState();
}

class _DetailProvinsiPageState extends State<DetailProvinsiPage> {
  final WilayahRepository _wilayahRepository = WilayahRepository();
  final ProgresWilayahRepository _progresRepository =
      ProgresWilayahRepository();
  final BookmarkRepository _bookmarkRepository = BookmarkRepository();

  int _jumlahArsip = 0;
  List<HasilJelajah> _rekomendasi = [];
  ProgresProvinsi? _progres;
  bool _tersimpan = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _muatData();
    _periksaBookmark();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String get _kunciBookmark =>
      BookmarkItemModel.kunciProvinsi(widget.provinsi.nama);

  Future<void> _periksaBookmark() async {
    final tersimpan = await _bookmarkRepository.isBookmarked(_kunciBookmark);
    if (!mounted) return;
    setState(() => _tersimpan = tersimpan);
  }

  Future<void> _ubahBookmark() async {
    final messenger = ScaffoldMessenger.of(context);
    final kini = await _bookmarkRepository.toggleBookmark(
      'provinsi',
      _kunciBookmark,
    );
    if (!mounted) return;

    setState(() => _tersimpan = kini);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          kini
              ? 'Berhasil disimpan ke Bookmark'
              : 'Berhasil dihapus dari Bookmark',
        ),
        duration: const Duration(milliseconds: 1200),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _bagikan() => bagikanArsip(
    context,
    judul: widget.provinsi.nama,
    jenis: 'Provinsi',
    keterangan: widget.provinsi.deskripsi,
    provinsi: null,
  );

  static final Map<String, (int, List<HasilJelajah>, ProgresProvinsi?)> _cacheProvinsi = {};

  // section muat data
  Future<void> _muatData({bool showLoader = true}) async {
    final nama = widget.provinsi.nama;
    final cached = _cacheProvinsi[nama];
    if (cached != null) {
      _jumlahArsip = cached.$1;
      _rekomendasi = cached.$2;
      _progres = cached.$3;
      _isLoading = false;
      if (!showLoader) return;
    }

    final results = await Future.wait([
      _wilayahRepository.jumlahArsipProvinsi(nama),
      _wilayahRepository.arsipAcakProvinsi(nama, jumlah: 5),
      _progresRepository.progresProvinsi(nama),
    ]);
    final jumlah = results[0] as int;
    final acak = results[1] as List<HasilJelajah>;
    final progres = results[2] as ProgresProvinsi?;
    _cacheProvinsi[nama] = (jumlah, acak, progres);

    if (!mounted) return;
    setState(() {
      _jumlahArsip = jumlah;
      _rekomendasi = acak;
      _progres = progres;
      _isLoading = false;
    });
  }

  // Kartu penuntasan: tingkat sekarang, arsip yang belum dibaca, dan status
  // section kontainer penuntasan
  Widget _buildPenuntasan() {
    final progres = _progres;
    if (progres == null || progres.jumlahArsip == 0) {
      return const SizedBox.shrink();
    }

    final warna = progres.tingkat.warna;
    final total = progres.jumlahArsip;
    final dibaca = progres.arsipDibaca;
    final rasio = total > 0 ? (dibaca / total) : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: AppDekorasi.panelCapaian(
        warna,
        menonjol: progres.tingkat != TingkatWilayah.belum,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PENUNTASAN', style: AppTypography.eyebrow()),
                    const SizedBox(height: 2),
                    Text(
                      progres.tingkat.label,
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 24,
                        color: AppColors.textPrimary,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$dibaca/$total',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 22,
                  color: warna == AppColors.border ? AppColors.primary : warna,
                  height: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: rasio.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.surfaceMuted.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                warna == AppColors.border ? AppColors.primary : warna,
              ),
            ),
          ),

          if (progres.adaArsipBaru) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              color: AppColors.gold.withValues(alpha: 0.14),
              child: Row(
                children: [
                  const Icon(
                    Icons.fiber_new_rounded,
                    size: 18,
                    color: AppColors.gold,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${progres.selisihArsipBaru} arsip baru ditambahkan '
                      'sejak provinsi ini Anda tuntaskan.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          // tombol lihat rincian arsip
          GestureDetector(
            onTap: () async {
              await context.push(
                PenuntasanProvinsiPage(provinsi: widget.provinsi),
              );
              if (!mounted) return;
              await _muatData();
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.folder_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Lihat Rincian Arsip ($dibaca Dikunjungi, ${progres.belumDibaca.length} Belum)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _bukaArsipLengkap() async {
    await context.push(ArsipProvinsiPage(provinsi: widget.provinsi));
    if (!mounted) return;
    await _muatData();
  }

  @override
  Widget build(BuildContext context) {
    final provinsi = widget.provinsi;
    final pulau = pulauDariProvinsi(provinsi.nama);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: gambarProvinsi(provinsi).isNotEmpty
                        ? AppImageView(
                            imagePath: gambarProvinsi(provinsi),
                            fit: BoxFit.cover,
                          )
                        : _buildFallbackHeader(provinsi.nama, pulau?.nama),
                  ),
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.backgroundTransparent,
                            AppColors.background,
                          ],
                          stops: [0.35, 1],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: DetailTopBar(
                      isBookmarked: _tersimpan,
                      onBookmarkToggle: _ubahBookmark,
                      onShare: _bagikan,
                    ),
                  ),
                ],
              ),

              // judul & julukan
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (pulau != null)
                      Text(
                        'PULAU ${pulau.nama.toUpperCase()}',
                        style: AppTypography.eyebrow(
                          fontSize: 10.5,
                          color: AppColors.primaryDark,
                          letterSpacing: 1.4,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      provinsi.nama,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (provinsi.julukan.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        provinsi.julukan,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textDeep,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // kartu total arsip & ibukota
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 4),
                // IntrinsicHeight menyamakan tinggi kedua kartu
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: KartuStatistik(
                          ikon: Icons.inventory_2_outlined,
                          label: 'Total Arsip',
                          nilai: _isLoading ? '—' : '$_jumlahArsip',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: KartuStatistik(
                          ikon: Icons.account_balance_outlined,
                          label: 'Ibukota',
                          nilai: provinsi.ibukota,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (provinsi.deskripsi.isNotEmpty) ...[
                DetailSectionBlock(
                  title: 'Tentang Daerah',
                  content: provinsi.deskripsi,
                ),
              ],

              // section penuntasan
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                child: _buildPenuntasan(),
              ),

              // tombol menuju daftar arsip lengkap
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _bukaArsipLengkap,
                    icon: const Icon(
                      Icons.grid_view_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Lihat arsip secara detail',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // section rekomendasi arsip
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Arsip dari Daerah Ini',
                      style: AppTypography.editorialHeading(),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 1.5,
                      width: 48,
                      color: AppColors.primaryDark,
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    else if (_rekomendasi.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: AppDekorasi.radiusKartu,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          'Belum ada arsip yang tercatat berasal dari '
                          '${provinsi.nama}.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium(),
                        ),
                      )
                    else
                      ..._rekomendasi.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: KartuHasil(
                            item: item,
                            onTap: () async {
                              await bukaHasilJelajah(context, item);
                              if (!mounted) return;
                              await _muatData();
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // section header cadangan
  Widget _buildFallbackHeader(String nama, String? pulauNama) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark,
            AppColors.primary,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance_outlined,
              size: 48,
              color: AppColors.gold,
            ),
            const SizedBox(height: 8),
            Text(
              nama.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.white,
              ),
            ),
            if (pulauNama != null && pulauNama.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'PULAU ${pulauNama.toUpperCase()}',
                style: AppTypography.eyebrow(
                  fontSize: 10,
                  color: AppColors.perak,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
