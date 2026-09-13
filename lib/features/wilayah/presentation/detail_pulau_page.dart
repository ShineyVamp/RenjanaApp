import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../data/static/data_wilayah_nusantara.dart';
import '../../../core/extensions/navigation.dart';
import '../../../core/widgets/detail_section_block.dart';
import '../../../core/widgets/detail_top_bar.dart';
import 'package:renjana/features/bookmark/data/models/bookmark_model.dart';
import 'package:renjana/features/bookmark/data/repositories/bookmark_repository.dart';
import 'package:renjana/core/utils/share_helper.dart';
import 'package:renjana/features/wilayah/data/repositories/wilayah_repository.dart';
import 'detail_provinsi_page.dart';
import 'widgets/kartu_statistik.dart';
import 'widgets/peta_painter.dart';

class DetailPulauPage extends StatefulWidget {
  final GugusPulau pulau;

  const DetailPulauPage({super.key, required this.pulau});

  @override
  State<DetailPulauPage> createState() => _DetailPulauPageState();
}

class _DetailPulauPageState extends State<DetailPulauPage> {
  final WilayahRepository _wilayahRepository = WilayahRepository();
  final BookmarkRepository _bookmarkRepository = BookmarkRepository();

  RingkasanPulau? _ringkasan;
  bool _tersimpan = false;
  bool _isLoading = true;
  PetaGeometri? _geometri;

  @override
  void initState() {
    super.initState();
    _muatGeometri();
    _muatData();
    _periksaBookmark();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String get _kunciBookmark => BookmarkItemModel.kunciPulau(widget.pulau.id);

  Future<void> _periksaBookmark() async {
    final tersimpan = await _bookmarkRepository.isBookmarked(_kunciBookmark);
    if (!mounted) return;
    setState(() => _tersimpan = tersimpan);
  }

  Future<void> _ubahBookmark() async {
    final messenger = ScaffoldMessenger.of(context);
    final kini = await _bookmarkRepository.toggleBookmark(
      'pulau',
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
    judul: widget.pulau.nama,
    jenis: 'Gugus Pulau',
    keterangan: widget.pulau.deskripsi,
    provinsi: null,
  );

  Future<void> _muatGeometri() async {
    final geometri = await PetaGeometri.muat();
    if (!mounted) return;
    setState(() => _geometri = geometri);
  }

  Future<void> _muatData() async {
    final ringkasan = await _wilayahRepository.ringkasanPulau(widget.pulau);
    if (!mounted) return;
    setState(() {
      _ringkasan = ringkasan;
      _isLoading = false;
    });
  }

  Future<void> _bukaProvinsi(Provinsi provinsi) async {
    await context.push(DetailProvinsiPage(provinsi: provinsi));
    if (!mounted) return;
    await _muatData();
  }

  @override
  Widget build(BuildContext context) {
    final pulau = widget.pulau;
    final ringkasan = _ringkasan;

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
                    child: _buildSiluetHeader(pulau),
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

              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GUGUS PULAU',
                      style: AppTypography.eyebrow(
                        fontSize: 10.5,
                        color: AppColors.primaryDark,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pulau.nama,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // section statistik pulau
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 4),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: KartuStatistik(
                          ikon: Icons.inventory_2_outlined,
                          label: 'Total Arsip',
                          nilai: ringkasan == null ? '—' : '${ringkasan.total}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: KartuStatistik(
                          ikon: Icons.flag_outlined,
                          label: 'Provinsi',
                          nilai: '${pulau.provinsi.length}',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (pulau.deskripsi.isNotEmpty) ...[
                DetailSectionBlock(
                  title: 'Tentang Pulau',
                  content: pulau.deskripsi,
                ),
              ],

              // section daftar provinsi
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Provinsi di ${pulau.nama}',
                      style: AppTypography.editorialHeading(),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 1.5,
                      width: 48,
                      color: AppColors.primaryDark,
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(pulau.provinsi.length, (index) {
                      final provinsi = pulau.provinsi[index];
                      final jumlah = ringkasan?.jumlah(provinsi.nama) ?? 0;

                      return GestureDetector(
                        onTap: () => _bukaProvinsi(provinsi),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: AppColors.border),
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24,
                                child: Text(
                                  '${index + 1}'.padLeft(2, '0'),
                                  style: AppTypography.tag(
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      provinsi.nama,
                                      style: AppTypography.labelBold(
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      provinsi.ibukota,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                _isLoading ? '—' : '$jumlah arsip',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: jumlah > 0
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // section siluet header pulau
  Widget _buildSiluetHeader(GugusPulau pulau) {
    final geometri = _geometri;
    if (geometri == null) {
      return Container(
        color: const Color(0xFFEDE8DD),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final proyeksi = ProyeksiPeta.paskanKotak(
          size,
          lonMin: pulau.lonMin,
          latMax: pulau.latMax,
          lonMax: pulau.lonMax,
          latMin: pulau.latMin,
          tepiX: 28.0,
          tepiY: 28.0,
        );
        final pathIndonesia = proyeksi.bangunPath(geometri.indonesia);
        final pathTetangga = proyeksi.bangunPath(geometri.tetangga);

        return CustomPaint(
          size: size,
          painter: SiluetPulauPainter(
            pathIndonesia: pathIndonesia,
            pathTetangga: pathTetangga,
          ),
        );
      },
    );
  }
}
