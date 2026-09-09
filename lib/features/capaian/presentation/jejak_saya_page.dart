import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/routes/navigasi_arsip.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dekorasi.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/extensions/navigation.dart';
import '../../../core/widgets/app_bar_halaman.dart';
import '../../../core/widgets/kartu_hasil.dart';
import '../../../core/widgets/pesan_kosong.dart';
import '../../jelajah/data/models/hasil_jelajah_model.dart';
import '../../jelajah/data/repositories/jelajah_repository.dart';
import '../../wilayah/data/repositories/progres_wilayah_repository.dart';
import '../../wilayah/data/static/data_wilayah_nusantara.dart';
import '../../wilayah/presentation/detail_provinsi_page.dart';
import 'package:renjana/features/capaian/data/repositories/arsip_dibaca_repository.dart';

// Rincian dua angka di halaman profil: arsip yang pernah dibaca dan provinsi
// yang sudah tersentuh. Keduanya di satu halaman karena sama-sama menjawab
// pertanyaan "apa saja yang sudah saya kunjungi".
class JejakSayaPage extends StatefulWidget {
  // 0 membuka tab arsip, 1 membuka tab provinsi.
  final int tabAwal;

  const JejakSayaPage({super.key, this.tabAwal = 0});

  @override
  State<JejakSayaPage> createState() => _JejakSayaPageState();
}

class _JejakSayaPageState extends State<JejakSayaPage>
    with SingleTickerProviderStateMixin {
  final ArsipDibacaRepository _arsipDibacaRepository = ArsipDibacaRepository();
  final JelajahRepository _jelajahRepository = JelajahRepository();
  final ProgresWilayahRepository _progresRepository =
      ProgresWilayahRepository();

  late final TabController _tab;

  // Arsip dimuat sepotong demi sepotong; pembaca lama bisa punya ratusan.
  static const int _ukuranHalaman = 20;

  List<String> _refArsip = const [];
  List<HasilJelajah> _arsip = const [];
  List<MapEntry<Provinsi, TingkatWilayah>> _provinsi = const [];
  bool _isLoading = true;
  bool _memuatLagi = false;

  bool get _adaLagi => _arsip.length < _refArsip.length;

  @override
  void initState() {
    super.initState();
    _tab = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.tabAwal.clamp(0, 1),
    );
    _muatData();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _muatData() async {
    final refs = await _arsipDibacaRepository.semua();
    final arsip = await _jelajahRepository.ambilDariRiwayat(
      refs,
      batas: _ukuranHalaman,
    );
    final tingkat = await _progresRepository.tingkatSemuaProvinsi();
    if (!mounted) return;

    // hanya provinsi yang sudah tersentuh, urut dari tingkat tertinggi
    final tersentuh =
        semuaProvinsi
            .map(
              (p) => MapEntry(
                p,
                tingkat[p.nama.toLowerCase()] ?? TingkatWilayah.belum,
              ),
            )
            .where((e) => e.value != TingkatWilayah.belum)
            .toList()
          ..sort((a, b) {
            final urut = b.value.index.compareTo(a.value.index);
            return urut != 0 ? urut : a.key.nama.compareTo(b.key.nama);
          });

    setState(() {
      _refArsip = refs;
      _arsip = arsip;
      _provinsi = tersentuh;
      _isLoading = false;
    });
  }

  Future<void> _muatLagi() async {
    if (_memuatLagi || !_adaLagi) return;
    setState(() => _memuatLagi = true);

    final berikutnya = _refArsip
        .skip(_arsip.length)
        .take(_ukuranHalaman)
        .toList();
    final tambahan = await _jelajahRepository.ambilDariRiwayat(berikutnya);
    if (!mounted) return;
    setState(() {
      _arsip = [..._arsip, ...tambahan];
      _memuatLagi = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarHalaman(
        judul: 'Jejak Saya',
        bawah: TabBar(
          controller: _tab,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
          tabs: [
            Tab(text: 'ARSIP (${_refArsip.length})'),
            Tab(text: 'PROVINSI (${_provinsi.length})'),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : TabBarView(
                  controller: _tab,
                  children: [_buildDaftarArsip(), _buildDaftarProvinsi()],
                ),
        ),
      ),
    );
  }

  Widget _buildDaftarArsip() {
    if (_arsip.isEmpty) {
      return const PesanKosong(
        pesan:
            'Belum ada arsip yang tercatat dibaca. Sebuah arsip terhitung '
            'setelah halamannya dibuka satu setengah menit.',
        ikon: Icons.menu_book_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      itemCount: _arsip.length + (_adaLagi ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _arsip.length) return _buildTombolMuatLagi();

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: KartuHasil(
            item: _arsip[index],
            onTap: () async {
              await bukaHasilJelajah(context, _arsip[index]);
              if (!mounted) return;
              await _muatData();
            },
          ),
        );
      },
    );
  }

  Widget _buildTombolMuatLagi() {
    final sisa = _refArsip.length - _arsip.length;

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: const RoundedRectangleBorder(),
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

  Widget _buildDaftarProvinsi() {
    if (_provinsi.isEmpty) {
      return const PesanKosong(
        pesan:
            'Belum ada provinsi yang tersentuh. Bacalah satu arsip daerah '
            'untuk mulai mewarnai peta.',
        ikon: Icons.map_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      itemCount: _provinsi.length,
      itemBuilder: (context, index) {
        final provinsi = _provinsi[index].key;
        final tingkat = _provinsi[index].value;
        final warna = tingkat.warna;
        final pulau = pulauDariProvinsi(provinsi.nama);

        return GestureDetector(
          onTap: () async {
            await context.push(DetailProvinsiPage(provinsi: provinsi));
            if (!mounted) return;
            await _muatData();
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
            decoration: AppDekorasi.panelCapaian(warna),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: warna,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provinsi.nama,
                        style: AppTypography.labelBold(fontSize: 13.5),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${tingkat.label}${pulau == null ? '' : ' · ${pulau.nama}'}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
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
        );
      },
    );
  }
}
