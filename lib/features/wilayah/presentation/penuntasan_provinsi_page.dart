// section halaman penuntasan provinsi
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dekorasi.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/wilayah_nusantara.dart';
import '../../../core/widgets/app_bar_halaman.dart';
import '../../../core/widgets/grid_horizontal.dart';
import '../../../core/widgets/kartu_hasil.dart';
import '../../../core/widgets/pesan_kosong.dart';
import 'package:renjana/features/jelajah/data/models/hasil_jelajah_model.dart';
import 'package:renjana/app/routes/navigasi_arsip.dart';
import 'package:renjana/features/wilayah/data/repositories/progres_wilayah_repository.dart';
import 'kategori_arsip.dart';

class PenuntasanProvinsiPage extends StatefulWidget {
  final Provinsi provinsi;

  const PenuntasanProvinsiPage({super.key, required this.provinsi});

  @override
  State<PenuntasanProvinsiPage> createState() => _PenuntasanProvinsiPageState();
}

class _PenuntasanProvinsiPageState extends State<PenuntasanProvinsiPage>
    with SingleTickerProviderStateMixin {
  final ProgresWilayahRepository _progresRepository =
      ProgresWilayahRepository();

  late TabController _tabController;
  ProgresProvinsi? _progres;
  bool _isLoading = true;

  String _filterDikunjungi = kunciSemua;
  String _filterBelum = kunciSemua;

  static const double _lebarKartu = 340;
  static const double _tinggiKartu = 170;

  // section siklus hidup
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _muatData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // section muat data
  Future<void> _muatData() async {
    final progres = await _progresRepository.progresProvinsi(widget.provinsi.nama);
    if (!mounted) return;
    setState(() {
      _progres = progres;
      _isLoading = false;
    });
  }

  Future<void> _bukaArsip(HasilJelajah item) async {
    await bukaHasilJelajah(context, item);
    if (!mounted) return;
    await _muatData();
  }

  @override
  Widget build(BuildContext context) {
    final progres = _progres;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarHalaman(
        judul: 'Penuntasan ${widget.provinsi.nama}',
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : progres == null
              ? const Center(child: PesanKosong(pesan: 'Data tidak tersedia'))
              : Column(
                  children: [
                    // section kartu ringkasan
                    _buildRingkasanCapaian(progres),

                    // section tab navigasi
                    Container(
                      color: AppColors.surface,
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: AppColors.primary,
                        indicatorWeight: 3,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textSecondary,
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        tabs: [
                          Tab(text: 'Dikunjungi (${progres.arsipDibaca})'),
                          Tab(text: 'Belum Dikunjungi (${progres.belumDibaca.length})'),
                        ],
                      ),
                    ),

                    // section isi tab
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildTabContent(
                            items: progres.sudahDibaca,
                            kunciFilter: _filterDikunjungi,
                            onPilihFilter: (k) => setState(() => _filterDikunjungi = k),
                            pesanKosong: 'Belum ada arsip yang dikunjungi di provinsi ini.',
                          ),
                          _buildTabContent(
                            items: progres.belumDibaca,
                            kunciFilter: _filterBelum,
                            onPilihFilter: (k) => setState(() => _filterBelum = k),
                            pesanKosong: 'Seluruh arsip provinsi ini telah selesai Anda kunjungi.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  // section ringkasan capaian
  Widget _buildRingkasanCapaian(ProgresProvinsi progres) {
    final warna = progres.tingkat.warna;
    final total = progres.jumlahArsip;
    final dibaca = progres.arsipDibaca;
    final rasio = total > 0 ? (dibaca / total) : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
                    Text(
                      'STATUS CAPAIAN WILAYAH',
                      style: AppTypography.eyebrow(fontSize: 10),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      progres.tingkat.label,
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 22,
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
          const SizedBox(height: 12),
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
        ],
      ),
    );
  }

  // section isi tab daftar
  Widget _buildTabContent({
    required List<HasilJelajah> items,
    required String kunciFilter,
    required ValueChanged<String> onPilihFilter,
    required String pesanKosong,
  }) {
    if (items.isEmpty) {
      return Center(child: PesanKosong(pesan: pesanKosong));
    }

    final kelompok = kelompokkanPerKategori(items);
    final kunciTersedia = urutkanKunciKategori(kelompok.keys);

    final listTampil = kunciFilter == kunciSemua
        ? items
        : (kelompok[kunciFilter] ?? []);

    return Column(
      children: [
        // section filter kategori
        _buildFilterKategori(
          kunciTersedia: kunciTersedia,
          kunciTerpilih: kunciFilter,
          onPilih: onPilihFilter,
        ),

        // section daftar kartu
        Expanded(
          child: listTampil.isEmpty
              ? const Center(
                  child: PesanKosong(pesan: 'Tidak ada arsip untuk kategori ini.'),
                )
              : kunciFilter == kunciSemua
                  ? ListView(
                      padding: const EdgeInsets.only(top: 8, bottom: 32),
                      children: [
                        for (final k in kunciTersedia)
                          if ((kelompok[k] ?? []).isNotEmpty)
                            _buildSeksiKategori(k, kelompok[k]!),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                      itemCount: listTampil.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) => KartuHasil(
                        item: listTampil[index],
                        onTap: () => _bukaArsip(listTampil[index]),
                      ),
                    ),
        ),
      ],
    );
  }

  // section filter kategori
  Widget _buildFilterKategori({
    required List<String> kunciTersedia,
    required String kunciTerpilih,
    required ValueChanged<String> onPilih,
  }) {
    final semuaKunci = [kunciSemua, ...kunciTersedia];

    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: semuaKunci.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final kunci = semuaKunci[index];
          final label = kunci == kunciSemua ? 'Semua' : labelKategoriArsip(kunci);
          final terpilih = kunci == kunciTerpilih;

          return Center(
            child: GestureDetector(
              onTap: () => onPilih(kunci),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: terpilih ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: terpilih ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: terpilih ? FontWeight.bold : FontWeight.w600,
                    color: terpilih ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // section seksi kategori
  Widget _buildSeksiKategori(String kunci, List<HasilJelajah> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    labelKategoriArsip(kunci),
                    style: AppTypography.editorialHeading().copyWith(fontSize: 18),
                  ),
                ),
                Text(
                  '${items.length} arsip',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridHorizontal(
              key: ValueKey('$kunci-${items.length}'),
              jumlahItem: items.length,
              lebarKartu: _lebarKartu,
              tinggiKartu: _tinggiKartu,
              builder: (index) => KartuHasil(
                item: items[index],
                isiPenuh: true,
                onTap: () => _bukaArsip(items[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
