import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dekorasi.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/wilayah_nusantara.dart';
import '../../core/extensions/navigation.dart';
import '../../core/widgets/header_halaman.dart';
import '../../data/repositories/progres_wilayah_repository.dart';
import '../wilayah/detail_provinsi_page.dart';
import '../wilayah/detail_pulau_page.dart';
import 'widgets/peta_painter.dart';

class PetaPage extends StatefulWidget {
  const PetaPage({super.key});

  @override
  State<PetaPage> createState() => _PetaPageState();
}

class _PetaPageState extends State<PetaPage>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformasi = TransformationController();
  late final AnimationController _animasiController;
  Animation<Matrix4>? _animasiMatriks;

  PetaGeometri? _geometri;
  ProyeksiPeta? _proyeksi;
  Path? _pathIndonesia;
  Path? _pathTetangga;

  Size _ukuran = Size.zero;
  GugusPulau? _pulauAktif;

  // Pulau yang terakhir dibuka, tetap dipegang selama panel provinsi
  // beranimasi turun.
  GugusPulau? _pulauPanel;
  String? _provinsiAktif;

  final ProgresWilayahRepository _progresRepository =
      ProgresWilayahRepository();

  // Tingkat penuntasan tiap provinsi, kuncinya nama provinsi huruf kecil.
  Map<String, TingkatWilayah> _tingkat = const {};

  static const double _skalaMin = 1;
  static const double _skalaMaks = 12;

  @override
  void initState() {
    super.initState();
    _animasiController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 700),
        )..addListener(() {
          final nilai = _animasiMatriks?.value;
          if (nilai != null) _transformasi.value = nilai;
        });
    _transformasi.addListener(_saatTransformasiBerubah);
    _muatGeometri();
    _muatTingkat();
  }

  Future<void> _muatTingkat() async {
    final tingkat = await _progresRepository.tingkatSemuaProvinsi();
    if (!mounted) return;
    setState(() => _tingkat = tingkat);
  }

  // Banyaknya provinsi yang sudah tuntas pada satu pulau.
  int _tuntasDiPulau(GugusPulau gugus) => gugus.provinsi
      .where(
        (p) => switch (_tingkat[p.nama.toLowerCase()]) {
          TingkatWilayah.tuntas || TingkatWilayah.dikuasai => true,
          _ => false,
        },
      )
      .length;

  int get _tuntasNasional =>
      gugusPulauList.fold(0, (t, g) => t + _tuntasDiPulau(g));

  String _subPulau(GugusPulau gugus) {
    final tuntas = _tuntasDiPulau(gugus);
    if (tuntas == 0) return '${gugus.provinsi.length} PROVINSI';
    return '$tuntas/${gugus.provinsi.length} TUNTAS';
  }

  // Di level provinsi legenda menerangkan warna penanda; di level nasional ia
  // menerangkan arti angka pada penanda pulau. Keduanya hanya muncul setelah
  // ada capaian yang perlu dijelaskan.
  bool get _perluLegenda {
    final pulau = _pulauAktif;
    if (pulau == null) return _tuntasNasional > 0;
    return pulau.provinsi.any(
      (p) =>
          (_tingkat[p.nama.toLowerCase()] ?? TingkatWilayah.belum).adaCapaian,
    );
  }

  @override
  void dispose() {
    _transformasi.removeListener(_saatTransformasiBerubah);
    _transformasi.dispose();
    _animasiController.dispose();
    super.dispose();
  }

  void _saatTransformasiBerubah() {
    if (mounted) setState(() {});
  }

  Future<void> _muatGeometri() async {
    final geometri = await PetaGeometri.muat();
    if (!mounted) return;
    setState(() => _geometri = geometri);
    _siapkanProyeksi();
  }

  // Path dibangun ulang hanya saat ukuran layar atau geometri berubah.
  void _siapkanProyeksi() {
    final geometri = _geometri;
    if (geometri == null || _ukuran.isEmpty) return;

    final proyeksi = ProyeksiPeta.paskan(_ukuran);
    _proyeksi = proyeksi;
    _pathIndonesia = proyeksi.bangunPath(geometri.indonesia);
    _pathTetangga = proyeksi.bangunPath(geometri.tetangga);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _transformasi.value = _pulauAktif == null
          ? _matriksNasional()
          : _matriksPulau(_pulauAktif!);
    });
  }

  double get _skalaSekarang => _transformasi.value.getMaxScaleOnAxis();

  Matrix4 _matriksKotak(
    double lonMin,
    double latMax,
    double lonMax,
    double latMin,
    double isian, {
    double geserAtas = 0,
  }) {
    final proyeksi = _proyeksi!;
    final p0 = proyeksi.titik(lonMin, latMax);
    final p1 = proyeksi.titik(lonMax, latMin);

    final lebar = (p1.dx - p0.dx).abs();
    final tinggi = (p1.dy - p0.dy).abs();
    final skala = (isian * min(_ukuran.width / lebar, _ukuran.height / tinggi))
        .clamp(_skalaMin, _skalaMaks)
        .toDouble();

    final pusatX = (p0.dx + p1.dx) / 2;
    final pusatY = (p0.dy + p1.dy) / 2;

    return Matrix4.identity()
      ..translateByDouble(
        _ukuran.width / 2,
        _ukuran.height / 2 - geserAtas,
        0,
        1,
      )
      ..scaleByDouble(skala, skala, 1, 1)
      ..translateByDouble(-pusatX, -pusatY, 0, 1);
  }

  Matrix4 _matriksNasional() =>
      _matriksKotak(petaLonMin, petaLatMax, petaLonMax, petaLatMin, 0.95);

  Matrix4 _matriksPulau(GugusPulau pulau) => _matriksKotak(
    pulau.lonMin,
    pulau.latMax,
    pulau.lonMax,
    pulau.latMin,
    0.82,
    geserAtas: 26,
  );

  void _animasikanKe(Matrix4 tujuan, {int durasiMs = 700}) {
    _animasiMatriks = Matrix4Tween(begin: _transformasi.value, end: tujuan)
        .animate(
          CurvedAnimation(
            parent: _animasiController,
            curve: Curves.easeInOutCubic,
          ),
        );
    _animasiController
      ..duration = Duration(milliseconds: durasiMs)
      ..forward(from: 0);
  }

  void _bukaPulau(GugusPulau pulau) {
    setState(() {
      _pulauAktif = pulau;
      _pulauPanel = pulau;
      _provinsiAktif = null;
    });
    _animasikanKe(_matriksPulau(pulau), durasiMs: 750);
  }

  void _kembaliNasional() {
    setState(() {
      _pulauAktif = null;
      _provinsiAktif = null;
    });
    _animasikanKe(_matriksNasional(), durasiMs: 750);
  }

  Future<void> _bukaDetailPulau(GugusPulau pulau) async {
    await context.push(DetailPulauPage(pulau: pulau));
  }

  Future<void> _bukaProvinsi(Provinsi provinsi) async {
    setState(() => _provinsiAktif = provinsi.nama);

    final proyeksi = _proyeksi!;
    final titik = proyeksi.titik(provinsi.lon, provinsi.lat);
    final skala = max(
      _skalaSekarang,
      4.0,
    ).clamp(_skalaMin, _skalaMaks).toDouble();
    _animasikanKe(
      Matrix4.identity()
        ..translateByDouble(_ukuran.width / 2, _ukuran.height / 2 - 40, 0, 1)
        ..scaleByDouble(skala, skala, 1, 1)
        ..translateByDouble(-titik.dx, -titik.dy, 0, 1),
      durasiMs: 600,
    );

    await context.push(DetailProvinsiPage(provinsi: provinsi));
    if (!mounted) return;
    await _muatTingkat();
  }

  void _ubahSkala(double faktor) {
    final sekarang = _skalaSekarang;
    final target = (sekarang * faktor).clamp(_skalaMin, _skalaMaks).toDouble();
    if ((target - sekarang).abs() < 0.001) return;

    final pusat = Offset(_ukuran.width / 2, _ukuran.height / 2);
    final rasio = target / sekarang;

    // dikalikan dari kiri, dengan titik jangkar tengah layar
    final perbesaran = Matrix4.identity()
      ..translateByDouble(pusat.dx, pusat.dy, 0, 1)
      ..scaleByDouble(rasio, rasio, 1, 1)
      ..translateByDouble(-pusat.dx, -pusat.dy, 0, 1);

    _animasikanKe(perbesaran.multiplied(_transformasi.value), durasiMs: 280);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeaderHalaman(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final ukuran = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  if (ukuran != _ukuran) {
                    _ukuran = ukuran;
                    _siapkanProyeksi();
                  }
                  if (_pathIndonesia == null) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }
                  return _buildPeta();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // section header halaman
  Widget _buildHeaderHalaman() {
    return HeaderHalaman(
      judul: 'Peta',
      garisBawah: false,
      aksi: Text(
        '$jumlahProvinsi PROVINSI',
        style: AppTypography.eyebrow(
          fontSize: 9.5,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }

  Widget _buildPeta() {
    return ClipRect(
      child: Stack(
        children: [
          InteractiveViewer(
            transformationController: _transformasi,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            minScale: _skalaMin,
            maxScale: _skalaMaks,
            child: SizedBox(
              width: _ukuran.width,
              height: _ukuran.height,
              child: CustomPaint(
                painter: PetaPainter(
                  pathIndonesia: _pathIndonesia!,
                  pathTetangga: _pathTetangga!,
                  skalaTampilan: _skalaSekarang,
                ),
              ),
            ),
          ),

          ..._buildPenanda(),
          _buildTopBar(),
          _buildKontrolZoom(),
          _buildLegenda(),
          _buildHintBar(),
          _buildPanelProvinsi(),
        ],
      ),
    );
  }

  // penanda pulau saat tampilan nasional, penanda provinsi saat pulau dibuka
  List<Widget> _buildPenanda() {
    final proyeksi = _proyeksi;
    if (proyeksi == null) return const [];

    final matriks = _transformasi.value;
    final pulau = _pulauAktif;
    final penanda = <Widget>[];

    void tambah({
      required double lon,
      required double lat,
      required String judul,
      required String sub,
      required bool modeProvinsi,
      required bool aktif,
      required VoidCallback onTap,
      TingkatWilayah? tingkat,
    }) {
      final layar = MatrixUtils.transformPoint(
        matriks,
        proyeksi.titik(lon, lat),
      );
      if (layar.dx < -80 ||
          layar.dx > _ukuran.width + 80 ||
          layar.dy < -60 ||
          layar.dy > _ukuran.height + 60) {
        return;
      }

      penanda.add(
        Positioned(
          left: layar.dx,
          top: layar.dy,
          child: FractionalTranslation(
            translation: const Offset(-0.5, -1),
            child: _Penanda(
              judul: judul,
              sub: sub,
              modeProvinsi: modeProvinsi,
              aktif: aktif,
              tingkat: tingkat,
              onTap: onTap,
            ),
          ),
        ),
      );
    }

    if (pulau == null) {
      for (final gugus in gugusPulauList) {
        tambah(
          lon: gugus.lon,
          lat: gugus.lat,
          judul: gugus.nama.toUpperCase(),
          sub: _subPulau(gugus),
          modeProvinsi: false,
          aktif: false,
          onTap: () => _bukaPulau(gugus),
        );
      }
    } else {
      for (final provinsi in pulau.provinsi) {
        tambah(
          lon: provinsi.lon,
          lat: provinsi.lat,
          judul: provinsi.nama.toUpperCase(),
          sub: provinsi.ibukota.toUpperCase(),
          modeProvinsi: true,
          aktif: _provinsiAktif == provinsi.nama,
          tingkat: _tingkat[provinsi.nama.toLowerCase()],
          onTap: () => _bukaProvinsi(provinsi),
        );
      }
    }
    return penanda;
  }

  Widget _buildTopBar() {
    final pulau = _pulauAktif;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.background,
              AppColors.backgroundTransparent,
            ],
            stops: [0, 0.55, 1],
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pulau != null) ...[
              GestureDetector(
                onTap: _kembaliNasional,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: AppDekorasi.radiusKecil,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    '‹ NUSANTARA',
                    style: AppTypography.eyebrow(
                      fontSize: 11,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pulau == null ? 'PETA NUSANTARA' : 'GUGUS PULAU',
                    style: AppTypography.eyebrow(letterSpacing: 1.4),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    pulau?.nama ?? 'Indonesia',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 24,
                      height: 1.1,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pulau == null
                        ? '$_tuntasNasional dari $jumlahProvinsi provinsi '
                              'sudah tuntas'
                        : '${pulau.provinsi.length} provinsi · '
                              'ketuk provinsi untuk membuka arsip',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKontrolZoom() {
    Widget tombol(String label, VoidCallback onTap, {double fontSize = 20}) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: AppDekorasi.radiusKecil,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: fontSize,
              height: 1,
              fontWeight: fontSize < 12 ? FontWeight.w800 : FontWeight.w400,
              letterSpacing: fontSize < 12 ? 0.5 : 0,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    return Positioned(
      right: 14,
      bottom: 120,
      child: Column(
        children: [
          tombol('+', () => _ubahSkala(1.6)),
          const SizedBox(height: 8),
          tombol('−', () => _ubahSkala(0.625)),
          const SizedBox(height: 8),
          tombol('RESET', _kembaliNasional, fontSize: 9),
        ],
      ),
    );
  }

  // Keterangan capaian, isinya menyesuaikan level yang sedang dibuka.
  Widget _buildLegenda() {
    if (!_perluLegenda) return const SizedBox.shrink();
    if (_pulauAktif == null) return _buildKeteranganPulau();

    Widget baris(Color warna, String teks) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: warna, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              teks,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Positioned(
      left: 16,
      top: 96,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 12, 6),
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.92),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PENUNTASAN',
              style: AppTypography.eyebrow(fontSize: 8.5, letterSpacing: 1),
            ),
            const SizedBox(height: 5),
            baris(AppColors.perunggu, 'Dikunjungi'),
            baris(AppColors.perak, 'Semua arsip dibaca'),
            baris(AppColors.gold, 'Ditambah kuis sempurna'),
          ],
        ),
      ),
    );
  }

  // Penjelasan angka pada penanda pulau, mis. "2/10 TUNTAS".
  Widget _buildKeteranganPulau() {
    return Positioned(
      left: 16,
      top: 96,
      right: 70,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 12, 9),
        decoration: AppDekorasi.kontrolPeta(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ANGKA PADA PENANDA',
              style: AppTypography.eyebrow(fontSize: 8.5, letterSpacing: 1),
            ),
            const SizedBox(height: 4),
            Text(
              'Provinsi yang seluruh arsipnya sudah Anda baca, dibanding '
              'jumlah provinsi di pulau itu.',
              style: AppTypography.caption(fontSize: 10, height: 1.35),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHintBar() {
    return Positioned(
      left: 16,
      bottom: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.9),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          _pulauAktif == null
              ? 'Geser peta · ketuk penanda pulau'
              : 'Geser peta · ketuk penanda provinsi',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10.5,
            letterSpacing: 0.2,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // panel daftar provinsi, muncul saat sebuah gugus pulau dibuka
  Widget _buildPanelProvinsi() {
    final pulau = _pulauPanel;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedSlide(
        offset: _pulauAktif == null ? const Offset(0, 1.01) : Offset.zero,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        child: pulau == null
            ? const SizedBox(width: double.infinity)
            : Container(
                constraints: BoxConstraints(maxHeight: _ukuran.height * 0.46),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  border: Border(
                    top: BorderSide(color: AppColors.primary, width: 0.8),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Provinsi di ${pulau.nama}',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 17,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${pulau.provinsi.length} provinsi · pilih untuk '
                        'melihat koleksi budaya & sejarahnya',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // pintasan ke halaman detail pulau
                      GestureDetector(
                        onTap: () => _bukaDetailPulau(pulau),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: AppDekorasi.panel(),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.travel_explore_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Lihat detail Pulau ${pulau.nama}',
                                  style: AppTypography.labelBold(
                                    fontSize: 12.5,
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
                      const SizedBox(height: 12),
                      ...List.generate(pulau.provinsi.length, (i) {
                        final provinsi = pulau.provinsi[i];
                        final terakhir = i == pulau.provinsi.length - 1;
                        return GestureDetector(
                          onTap: () => _bukaProvinsi(provinsi),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              border: terakhir
                                  ? null
                                  : const Border(
                                      bottom: BorderSide(
                                        color: AppColors.border,
                                      ),
                                    ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 18,
                                  child: Text(
                                    '${i + 1}'.padLeft(2, '0'),
                                    style: AppTypography.eyebrow(
                                      fontSize: 9.5,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    provinsi.nama,
                                    style: AppTypography.labelBold(
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${provinsi.ibukota} ›',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

// penanda peta: chip label, batang, lalu titik yang menempel di koordinat
class _Penanda extends StatelessWidget {
  final String judul;
  final String sub;
  final bool modeProvinsi;
  final bool aktif;
  final VoidCallback onTap;

  // Tingkat penuntasan provinsi; null pada penanda pulau.
  final TingkatWilayah? tingkat;

  const _Penanda({
    required this.judul,
    required this.sub,
    required this.modeProvinsi,
    required this.aktif,
    required this.onTap,
    this.tingkat,
  });

  @override
  Widget build(BuildContext context) {
    // Warna capaian dipakai pada seluruh kartu penanda, bukan hanya titiknya,
    // supaya perubahannya langsung terlihat.
    final capaian = (tingkat ?? TingkatWilayah.belum).adaCapaian
        ? tingkat!.warna
        : null;

    final warnaChip = aktif
        ? AppColors.textPrimary
        : (modeProvinsi ? AppColors.surface : AppColors.primary);
    final warnaTeks = (modeProvinsi && !aktif)
        ? AppColors.textPrimary
        : Colors.white;
    final warnaSub = (modeProvinsi && !aktif)
        ? AppColors.primaryDark
        : Colors.white.withValues(alpha: 0.85);
    final warnaBatang =
        capaian ?? (modeProvinsi ? AppColors.primaryDark : AppColors.primary);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(capaian == null ? 8 : 6, 3, 8, 3),
            decoration: BoxDecoration(
              color: warnaChip,
              border: capaian != null
                  ? Border(
                      left: BorderSide(color: capaian, width: 4),
                      top: BorderSide(color: capaian),
                      right: BorderSide(color: capaian),
                      bottom: BorderSide(color: capaian),
                    )
                  : (modeProvinsi && !aktif
                        ? Border.all(
                            color: AppColors.primary.withValues(alpha: 0.45),
                          )
                        : null),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  judul,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: modeProvinsi
                        ? FontWeight.w700
                        : FontWeight.w800,
                    letterSpacing: 0.4,
                    color: warnaTeks,
                  ),
                ),
                Text(
                  sub,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    color: warnaSub,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1.5, height: 9, color: warnaBatang),
          Container(
            width: capaian == null ? 9 : 12,
            height: capaian == null ? 9 : 12,
            decoration: BoxDecoration(
              color: warnaBatang,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.background, width: 2),
            ),
          ),
        ],
      ),
    );
  }
}
