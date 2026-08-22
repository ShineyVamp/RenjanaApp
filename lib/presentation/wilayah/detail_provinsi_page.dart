import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/wilayah_nusantara.dart';
import '../../core/extensions/navigation.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/detail_section_block.dart';
import '../../core/widgets/kartu_hasil.dart';
import '../../data/models/hasil_jelajah_model.dart';
import '../../data/repositories/wilayah_repository.dart';
import '../navigasi_arsip.dart';
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

  int _jumlahArsip = 0;
  List<HasilJelajah> _rekomendasi = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    final nama = widget.provinsi.nama;
    final jumlah = await _wilayahRepository.jumlahArsipProvinsi(nama);
    final acak = await _wilayahRepository.arsipAcakProvinsi(nama, jumlah: 5);
    if (!mounted) return;
    setState(() {
      _jumlahArsip = jumlah;
      _rekomendasi = acak;
      _isLoading = false;
    });
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          provinsi.nama,
          style: AppTypography.headingSmall().copyWith(fontSize: 19),
        ),
        shape: const Border(
          bottom: BorderSide(color: AppColors.primary, width: 0.8),
        ),
      ),
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
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                            color: AppColors.primaryDark,
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

                if (provinsi.deskripsi.isNotEmpty)
                  DetailSectionBlock(
                    title: 'Tentang Daerah',
                    content: provinsi.deskripsi,
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
