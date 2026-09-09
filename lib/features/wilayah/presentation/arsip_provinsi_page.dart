import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dekorasi.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/wilayah_nusantara.dart';
import '../../../core/extensions/navigation.dart';
import '../../../core/widgets/app_bar_halaman.dart';
import '../../../core/widgets/grid_horizontal.dart';
import '../../../core/widgets/kartu_hasil.dart';
import '../../../core/widgets/kotak_pencarian.dart';
import '../../../core/widgets/pesan_kosong.dart';
import 'package:renjana/features/jelajah/data/models/hasil_jelajah_model.dart';
import 'package:renjana/app/routes/navigasi_arsip.dart';
import 'package:renjana/features/wilayah/data/repositories/wilayah_repository.dart';
import 'arsip_kategori_page.dart';
import 'kategori_arsip.dart';

class ArsipProvinsiPage extends StatefulWidget {
  final Provinsi provinsi;

  const ArsipProvinsiPage({super.key, required this.provinsi});

  @override
  State<ArsipProvinsiPage> createState() => _ArsipProvinsiPageState();
}

class _ArsipProvinsiPageState extends State<ArsipProvinsiPage> {
  final WilayahRepository _wilayahRepository = WilayahRepository();
  final TextEditingController _controller = TextEditingController();

  // banyaknya kartu yang tampil di grid sebelum dibuka lengkap
  static const int _batasGrid = 9;
  static const double _lebarKartu = 350;

  // tinggi kartu, cukup untuk judul dan subjudul dua baris
  static const double _tinggiKartu = 170;

  List<HasilJelajah> _semua = [];
  String _query = '';
  String _filter = kunciSemua;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _muatData() async {
    final daftar = await _wilayahRepository.arsipProvinsi(widget.provinsi.nama);
    if (!mounted) return;
    setState(() {
      _semua = daftar;
      _isLoading = false;
    });
  }

  Future<void> _bukaArsip(HasilJelajah item) async {
    await bukaHasilJelajah(context, item);
    if (!mounted) return;
    await _muatData();
  }

  Future<void> _bukaKategoriLengkap(String kunci) async {
    await context.push(
      ArsipKategoriPage(provinsi: widget.provinsi, kunciKategori: kunci),
    );
    if (!mounted) return;
    await _muatData();
  }

  @override
  Widget build(BuildContext context) {
    final tersaring = saringArsip(_semua, _query);
    final kelompok = kelompokkanPerKategori(tersaring);

    // chip hanya memuat kategori yang ada isinya di provinsi ini
    final kunciTersedia = urutkanKunciKategori(
      kelompokkanPerKategori(_semua).keys,
    );
    final kunciTampil = urutkanKunciKategori(
      kelompok.keys,
    ).where((k) => _filter == kunciSemua || k == _filter).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarHalaman(judul: 'Arsip ${widget.provinsi.nama}'),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              _buildPenyaring(kunciTersedia),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : kunciTampil.isEmpty
                    ? PesanKosong(
                        pesan: _semua.isEmpty
                            ? 'Belum ada arsip yang tercatat berasal dari '
                                  '${widget.provinsi.nama}.'
                            : 'Tidak ada hasil untuk "${_query.trim()}".',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
                        itemCount: kunciTampil.length,
                        itemBuilder: (context, index) {
                          final kunci = kunciTampil[index];
                          return _buildSeksi(
                            kunci,
                            kelompok[kunci] ?? const [],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // section pencarian dan chip filter kategori
  Widget _buildPenyaring(List<String> kunciTersedia) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
      decoration: AppDekorasi.barisDaftar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KotakPencarian(
            controller: _controller,
            petunjuk: 'Cari arsip di ${widget.provinsi.nama}…',
            onChanged: (nilai) => setState(() => _query = nilai),
            onBersihkan: () {
              _controller.clear();
              setState(() => _query = '');
            },
          ),
          if (kunciTersedia.length > 1) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildChip(kunciSemua, 'Semua'),
                  ...kunciTersedia.map(
                    (kunci) => _buildChip(kunci, labelKategoriArsip(kunci)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(String kunci, String label) {
    final terpilih = _filter == kunci;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filter = kunci),
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
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
              color: terpilih ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  // satu seksi kategori: judul, tombol lihat lainnya, lalu grid
  Widget _buildSeksi(String kunci, List<HasilJelajah> items) {
    final tampil = items.take(_batasGrid).toList();
    final adaSisa = items.length > tampil.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        labelKategoriArsip(kunci),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.editorialHeading().copyWith(
                          fontSize: 19,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${items.length} arsip',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _bukaKategoriLengkap(kunci),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          adaSisa ? 'Lihat lainnya' : 'Lihat semua',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridHorizontal(
              key: ValueKey('$kunci-${tampil.length}-$_query'),
              jumlahItem: tampil.length,
              lebarKartu: _lebarKartu,
              tinggiKartu: _tinggiKartu,
              builder: (index) => KartuHasil(
                item: tampil[index],
                isiPenuh: true,
                onTap: () => _bukaArsip(tampil[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
