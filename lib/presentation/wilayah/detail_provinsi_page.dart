import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dekorasi.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/wilayah_nusantara.dart';
import '../../core/extensions/navigation.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/detail_section_block.dart';
import '../../core/widgets/detail_top_bar.dart';
import '../../core/widgets/kartu_hasil.dart';
import '../../core/widgets/tombol_suara_arsip.dart';
import '../../data/models/bookmark_model.dart';
import '../../data/models/hasil_jelajah_model.dart';
import '../../data/repositories/bookmark_repository.dart';
import '../../data/repositories/progres_wilayah_repository.dart';
import '../../data/repositories/quiz_repository.dart';
import '../../data/repositories/wilayah_repository.dart';
import '../../services/pembaca_arsip.dart';
import '../../services/pembagi_arsip.dart';
import '../navigasi_arsip.dart';
import '../quiz/mulai_kuis.dart';
import 'arsip_provinsi_page.dart';
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
  final QuizRepository _quizRepository = QuizRepository();
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
    PembacaArsip().berhenti();
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

  Future<void> _muatData() async {
    final nama = widget.provinsi.nama;
    final jumlah = await _wilayahRepository.jumlahArsipProvinsi(nama);
    final acak = await _wilayahRepository.arsipAcakProvinsi(nama, jumlah: 5);
    final progres = await _progresRepository.progresProvinsi(nama);
    if (!mounted) return;
    setState(() {
      _jumlahArsip = jumlah;
      _rekomendasi = acak;
      _progres = progres;
      _isLoading = false;
    });
  }

  // Kartu penuntasan: tingkat sekarang, arsip yang belum dibaca, dan status
  // kuis provinsi. Muncul juga penanda bila ada arsip yang baru ditambahkan.
  Widget _buildPenuntasan() {
    final progres = _progres;
    if (progres == null || progres.jumlahArsip == 0) {
      return const SizedBox.shrink();
    }

    final warna = progres.tingkat.warna;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 6),
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
                '${progres.arsipDibaca}/${progres.jumlahArsip}',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 22,
                  color: warna == AppColors.border ? AppColors.primary : warna,
                  height: 1,
                ),
              ),
            ],
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

          const SizedBox(height: 6),
          ...progres.belumDibaca.map(
            (item) => _buildBarisTugas(
              'Baca ${item.judul}',
              selesai: false,
              onTap: () async {
                await bukaHasilJelajah(context, item);
                if (!mounted) return;
                await _muatData();
              },
            ),
          ),
          if (progres.belumDibaca.isEmpty)
            _buildBarisTugas(
              'Seluruh arsip provinsi ini sudah dibaca',
              selesai: true,
            ),
          _buildBarisTugas(
            progres.kuisSempurna
                ? 'Kuis "${progres.temaKuis}" sudah sempurna'
                : 'Kerjakan kuis "${progres.temaKuis}" tanpa salah',
            selesai: progres.kuisSempurna,
            onTap: () async {
              await _kerjakanKuis(progres.temaKuis);
              if (!mounted) return;
              await _muatData();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBarisTugas(
    String teks, {
    required bool selesai,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: AppDekorasi.barisAtas,
        child: Row(
          children: [
            Icon(
              selesai
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 17,
              color: selesai ? AppColors.gold : AppColors.surfaceMuted,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                teks,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selesai
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                ),
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.chevron_right_rounded,
                size: 17,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  // Mengerjakan tema kuis provinsi ini. Soalnya diambil saat ditekan karena
  // admin bisa menambah atau mengurangi isinya kapan saja.
  Future<void> _kerjakanKuis(String tema) async {
    final soal = await _quizRepository.getQuizByTema(tema);
    if (!mounted) return;

    if (soal.isEmpty) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Belum ada soal untuk tema "$tema".'),
          backgroundColor: AppColors.primaryDark,
        ),
      );
      return;
    }

    mulaiKuisGabungan(
      context,
      judul: tema,
      kategori: soal.first.kategori,
      soal: soal,
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // gambar utama, bagian bawahnya dileburkan ke warna latar
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: AppImageView(
                        imagePath: gambarProvinsi(provinsi),
                        fit: BoxFit.cover,
                      ),
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

                    // Top bar harus jadi anak terakhir Stack. Lapisan gradien
                    // di atas menjawab true pada hit test, jadi apa pun yang
                    // berada di bawahnya tidak bisa disentuh.
                    // tombol kembali, beranda, simpan, dan bagikan
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
                  TombolSuaraArsip(
                    teksNarasi:
                        '${provinsi.nama}. ${provinsi.julukan.isNotEmpty ? 'Dijuluki ${provinsi.julukan}. ' : ''}Ibukota ${provinsi.ibukota}. ${provinsi.deskripsi}',
                    judul: provinsi.nama,
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
      ),
    );
  }
}
