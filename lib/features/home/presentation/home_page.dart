import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dekorasi.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/extensions/navigation.dart';
import '../../bookmark/presentation/bookmark_page.dart';
import '../../budaya/data/models/budaya_model.dart';
import '../../budaya/data/repositories/budaya_repository.dart';
import '../../kontribusi/presentation/kontribusi_page.dart';
import '../../quiz/presentation/quiz_page.dart';
import '../../sejarah/data/models/sejarah_model.dart';
import '../../sejarah/data/repositories/sejarah_repository.dart';
import 'widgets/banner_kuis.dart';
import 'widgets/banner_melestarikan.dart';
import 'widgets/budaya_highlight_card.dart';
import 'widgets/garis_waktu_list.dart';
import 'widgets/koleksi_budaya_list.dart';
import 'widgets/misi_harian_card.dart';
import 'widgets/pilihan_destinasi_list.dart';
import 'widgets/sejarah_highlight_card.dart';

// Ruang kosong selagi sorotan harian dimuat.
class _HighlightPlaceholder extends StatelessWidget {
  const _HighlightPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: AppDekorasi.radiusKartu,
        border: Border.all(color: AppColors.borderPrimary),
      ),
      child: const CircularProgressIndicator(color: AppColors.primary),
    );
  }
}

class HomePage extends StatefulWidget {
  final String userName;
  final bool isAdmin;
  final VoidCallback? onOpenDrawer;

  const HomePage({
    super.key,
    this.userName = 'Agus',
    this.isAdmin = false,
    this.onOpenDrawer,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  final SejarahRepository _sejarahRepository = SejarahRepository();
  final BudayaRepository _budayaRepository = BudayaRepository();

  SejarahModel? _sejarahHariIni;
  BudayaModel? _budayaHariIni;

  // Diganti untuk memaksa kartu misi harian membangun ulang dan memuat
  // datanya lagi, tanpa beranda perlu memegang state kartu itu.
  int _revisiMisi = 0;

  final ScrollController _gulir = ScrollController();

  // Header menghilang begitu pengguna menggulir turun, dan baru kembali
  // setelah digulir naik sejauh ambangnya. Keduanya diukur dari jarak gerakan,
  // bukan posisi mutlak, supaya perilakunya sama di bagian mana pun halaman.
  static const double _ambangMunculHeader = 350;
  static const double _ambangSembunyiHeader = 40;
  static const double _tinggiHeader = 58;

  bool _headerTampil = true;
  double _gulirTerakhir = 0;
  double _akumulasiNaik = 0;
  double _akumulasiTurun = 0;

  @override
  void initState() {
    super.initState();
    _loadFromRepository();
    _gulir.addListener(_saatMenggulir);
  }

  void _saatMenggulir() {
    final posisi = _gulir.position.pixels;
    final selisih = posisi - _gulirTerakhir;
    _gulirTerakhir = posisi;

    // di puncak halaman header selalu tampil
    if (posisi <= _tinggiHeader) {
      _akumulasiNaik = 0;
      _akumulasiTurun = 0;
      if (!_headerTampil) setState(() => _headerTampil = true);
      return;
    }

    // menggulir turun: header disembunyikan setelah gerakan cukup jauh
    if (selisih > 0) {
      _akumulasiNaik = 0;
      _akumulasiTurun += selisih;
      if (_headerTampil && _akumulasiTurun >= _ambangSembunyiHeader) {
        setState(() => _headerTampil = false);
      }
      return;
    }

    // menggulir naik: header kembali setelah naik sejauh ambangnya
    _akumulasiTurun = 0;
    _akumulasiNaik += -selisih;
    if (!_headerTampil && _akumulasiNaik >= _ambangMunculHeader) {
      setState(() => _headerTampil = true);
    }
  }

  // Dipakai tombol logo: kembali ke puncak halaman lalu memuat ulang isinya.
  Future<void> _keAtasDanSegarkan() async {
    if (_gulir.hasClients) {
      await _gulir.animateTo(
        0,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    }
    if (!mounted) return;
    await _segarkan();
  }

  Future<void> _bukaKontribusi() async {
    await context.push(const KontribusiPage());
    if (!mounted) return;
    await _segarkan();
  }

  Future<void> _bukaKuis() async {
    await context.push(QuizPage());
    if (!mounted) return;
    setState(() => _revisiMisi++);
  }

  Future<void> _segarkan() async {
    await _loadFromRepository();
    if (!mounted) return;
    setState(() => _revisiMisi++);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final rute = ModalRoute.of(context);
    if (rute is PageRoute) pengamatRute.subscribe(this, rute);
  }

  @override
  void dispose() {
    pengamatRute.unsubscribe(this);
    _gulir.removeListener(_saatMenggulir);
    _gulir.dispose();
    super.dispose();
  }

  // Dipanggil saat halaman yang menutupi beranda ditutup, mis. detail arsip.
  @override
  void didPopNext() {
    if (!mounted) return;
    setState(() => _revisiMisi++);
  }

  Future<void> _loadFromRepository() async {
    final sejarah = await _sejarahRepository.getSejarahHariIni();
    final budaya = await _budayaRepository.getBudayaHariIni();
    if (!mounted) return;
    setState(() {
      _sejarahHariIni = sejarah;
      _budayaHariIni = budaya;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        // top: false,
        bottom: false,
        child: Stack(
          children: [
            RefreshIndicator(
              color: AppColors.primary,
              edgeOffset: _tinggiHeader,
              onRefresh: _segarkan,
              child: SingleChildScrollView(
                controller: _gulir,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  0,
                  _tinggiHeader + 16,
                  0,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // section sapaan & tanggal
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat(
                              'EEEE, dd MMMM yyyy',
                              'id_ID',
                            ).format(DateTime.now()),
                            style: AppTypography.labelBold(
                              color: AppColors.primary,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Selamat pagi, ${widget.userName}',
                            style: AppTypography.headingMedium(),
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: AppColors.primary),
                          const SizedBox(height: 32),

                          // section sejarah hari ini
                          if (_sejarahHariIni != null)
                            SejarahHighlightCard(data: _sejarahHariIni!)
                          else
                            const _HighlightPlaceholder(),
                          const SizedBox(height: 48),

                          // section budaya hari ini
                          if (_budayaHariIni != null)
                            BudayaHighlightCard(data: _budayaHariIni!)
                          else
                            const _HighlightPlaceholder(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // section misi harian
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: MisiHarianCard(key: ValueKey(_revisiMisi)),
                    ),
                    const SizedBox(height: 28),

                    // section garis waktu nusantara (era sejarah)
                    const GarisWaktuList(),
                    const SizedBox(height: 28),

                    // section koleksi budaya
                    const KoleksiBudayaList(),
                    const SizedBox(height: 28),

                    // section pilihan destinasi
                    const PilihanDestinasiList(),
                    const SizedBox(height: 36),

                    // section banner kuis interaktif
                    BannerKuis(onStartQuiz: _bukaKuis),
                    const SizedBox(height: 24),

                    // section banner melestarikan
                    BannerMelestarikan(onContribute: _bukaKontribusi),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // header mengambang, tersembunyi selagi pengguna membaca
            AnimatedSlide(
              offset: _headerTampil ? Offset.zero : const Offset(0, -2),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: _buildHeader(),
            ),
          ],
        ),
      ),
    );
  }

  // section header: logo, penanda admin, dan pintasan koleksi
  Widget _buildHeader() {
    return Container(
      height: _tinggiHeader,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.primary, width: 0.8),
        ),
      ),
      child: Row(
        children: [
          if (widget.isAdmin) ...[
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(
                  Icons.menu_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
                padding: EdgeInsets.zero,
                onPressed:
                    widget.onOpenDrawer ?? () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // logo: kembali ke puncak halaman sekaligus memuat ulang
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _keAtasDanSegarkan,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/Rlogos.png', width: 30, height: 30),
                const SizedBox(width: 8),
                Text(
                  'RENJANA',
                  style: AppTypography.brandTitle().copyWith(fontSize: 25),
                ),
              ],
            ),
          ),
          if (widget.isAdmin) ...[
            const SizedBox(width: 8),
            Text(
              'ADMIN',
              style: AppTypography.eyebrow(
                fontSize: 9,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
          ],

          const Spacer(),
          IconButton(
            icon: const Icon(
              Icons.bookmark_outline_rounded,
              color: AppColors.primary,
              size: 24,
            ),
            tooltip: 'Koleksi Tersimpan',
            onPressed: () => context.push(const BookmarkPage()),
          ),
        ],
      ),
    );
  }
}
