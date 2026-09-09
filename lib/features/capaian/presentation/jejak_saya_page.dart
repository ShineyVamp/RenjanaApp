import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/routes/navigasi_arsip.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dekorasi.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/budaya_kategori.dart';
import '../../../core/extensions/navigation.dart';
import '../../../core/widgets/app_bar_halaman.dart';
import '../../../core/widgets/kartu_hasil.dart';
import '../../../core/widgets/kotak_pencarian.dart';
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
  final TextEditingController _cariController = TextEditingController();

  late final TabController _tab;

  List<HasilJelajah> _arsip = const [];
  List<MapEntry<Provinsi, TingkatWilayah>> _provinsi = const [];
  bool _isLoading = true;

  String _query = '';
  String _kunciFilter = 'SEMUA';

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
    _cariController.dispose();
    _tab.dispose();
    super.dispose();
  }

  Future<void> _muatData() async {
    final refs = await _arsipDibacaRepository.semua();
    final arsip = await _jelajahRepository.ambilDariRiwayat(refs);
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
      _arsip = arsip;
      _provinsi = tersentuh;
      _isLoading = false;
    });
  }

  List<_OpsiFilterArsip> _bangunOpsiFilter() {
    final jumlahSejarah =
        _arsip.where((a) => a.jenis == JenisArsip.sejarah).length;
    final jumlahBudaya =
        _arsip.where((a) => a.jenis == JenisArsip.budaya).length;
    final jumlahDestinasi = _arsip.where((a) => a.isDestinasi).length;

    // Hitung per kategori budaya
    final Map<String, int> jumlahPerKategori = {};
    for (final item in _arsip) {
      if (item.jenis == JenisArsip.budaya && item.budaya != null) {
        final kode = item.budaya!.jenis.trim().toUpperCase();
        jumlahPerKategori[kode] = (jumlahPerKategori[kode] ?? 0) + 1;
      }
    }

    final kategoriUrut = [
      for (final k in budayaKategoriList)
        if (jumlahPerKategori.containsKey(k.kode.toUpperCase()))
          k.kode.toUpperCase(),
      ...jumlahPerKategori.keys.where(
        (k) => !budayaKategoriList.any((b) => b.kode.toUpperCase() == k),
      ),
    ];

    return [
      _OpsiFilterArsip(
        kunci: 'SEMUA',
        label: 'Semua',
        jumlah: _arsip.length,
      ),
      if (jumlahSejarah > 0)
        _OpsiFilterArsip(
          kunci: 'SEJARAH',
          label: 'Sejarah',
          jumlah: jumlahSejarah,
        ),
      if (jumlahBudaya > 0)
        _OpsiFilterArsip(
          kunci: 'BUDAYA',
          label: 'Budaya',
          jumlah: jumlahBudaya,
        ),
      if (jumlahDestinasi > 0)
        _OpsiFilterArsip(
          kunci: 'DESTINASI',
          label: 'Destinasi',
          jumlah: jumlahDestinasi,
        ),
      for (final kode in kategoriUrut)
        _OpsiFilterArsip(
          kunci: 'KAT:$kode',
          label: namaKategori(kode),
          jumlah: jumlahPerKategori[kode]!,
        ),
    ];
  }

  List<HasilJelajah> _dapatkanArsipTersaring() {
    return _arsip.where((item) {
      // 1. Saring Kategori
      if (_kunciFilter == 'SEJARAH') {
        if (item.jenis != JenisArsip.sejarah) return false;
      } else if (_kunciFilter == 'BUDAYA') {
        if (item.jenis != JenisArsip.budaya) return false;
      } else if (_kunciFilter == 'DESTINASI') {
        if (!item.isDestinasi) return false;
      } else if (_kunciFilter.startsWith('KAT:')) {
        final kode = _kunciFilter.substring(4);
        if (item.jenis != JenisArsip.budaya) return false;
        if (item.budaya?.jenis.trim().toUpperCase() != kode) return false;
      }

      // 2. Saring Pencarian Teks
      final q = _query.trim().toLowerCase();
      if (q.isNotEmpty) {
        final sumber = [
          item.judul,
          item.sub,
          item.kodeTag,
          item.meta,
          item.asalProvinsi ?? '',
          item.isiPencarian,
        ].join(' ').toLowerCase();

        if (!sumber.contains(q)) return false;
      }

      return true;
    }).toList();
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
            Tab(text: 'ARSIP (${_arsip.length})'),
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

    final opsiFilter = _bangunOpsiFilter();
    final tersaring = _dapatkanArsipTersaring();

    return Column(
      children: [
        _buildPenyaringArsip(opsiFilter),
        Expanded(
          child: tersaring.isEmpty
              ? _buildArsipKosongTersaring()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                  itemCount: tersaring.length,
                  itemBuilder: (context, index) {
                    final item = tersaring[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: KartuHasil(
                        item: item,
                        onTap: () async {
                          await bukaHasilJelajah(context, item);
                          if (!mounted) return;
                          await _muatData();
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPenyaringArsip(List<_OpsiFilterArsip> opsi) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KotakPencarian(
            controller: _cariController,
            petunjuk: 'Cari di arsip yang telah dibaca…',
            onChanged: (nilai) => setState(() => _query = nilai),
            onBersihkan: () {
              _cariController.clear();
              setState(() => _query = '');
            },
          ),
          if (opsi.length > 1) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: opsi.map(_buildChip).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(_OpsiFilterArsip opsi) {
    final terpilih = _kunciFilter == opsi.kunci;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _kunciFilter = opsi.kunci),
        behavior: HitTestBehavior.opaque,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: terpilih ? AppColors.primary : AppColors.surface,
            borderRadius: AppDekorasi.radiusKecil,
            border: Border.all(
              color: terpilih ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            '${opsi.label.toUpperCase()} (${opsi.jumlah})',
            style: AppTypography.eyebrow(
              fontSize: 10.5,
              color: terpilih ? Colors.white : AppColors.textPrimary,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArsipKosongTersaring() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 46,
              color: AppColors.surfaceMuted,
            ),
            const SizedBox(height: 12),
            Text(
              _query.trim().isNotEmpty
                  ? 'Tidak ada arsip dibaca untuk "${_query.trim()}"'
                  : 'Tidak ada arsip dibaca di kategori ini',
              textAlign: TextAlign.center,
              style: AppTypography.labelBold(fontSize: 14.5),
            ),
            const SizedBox(height: 6),
            Text(
              _query.trim().isNotEmpty
                  ? 'Coba gunakan kata kunci lain atau ubah filter kategori.'
                  : 'Coba pilih filter lain untuk melihat arsip yang pernah dibaca.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: AppDekorasi.radiusKecil,
                ),
              ),
              onPressed: () {
                _cariController.clear();
                setState(() {
                  _query = '';
                  _kunciFilter = 'SEMUA';
                });
              },
              child: Text(
                'Reset Filter',
                style: AppTypography.labelBold(
                  fontSize: 12,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
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

class _OpsiFilterArsip {
  final String kunci;
  final String label;
  final int jumlah;

  const _OpsiFilterArsip({
    required this.kunci,
    required this.label,
    required this.jumlah,
  });
}
