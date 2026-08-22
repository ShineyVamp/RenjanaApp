import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/wilayah_nusantara.dart';
import '../../core/extensions/navigation.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/detail_section_block.dart';
import '../../data/repositories/wilayah_repository.dart';
import 'detail_provinsi_page.dart';
import 'widgets/kartu_statistik.dart';

class DetailPulauPage extends StatefulWidget {
  final GugusPulau pulau;

  const DetailPulauPage({super.key, required this.pulau});

  @override
  State<DetailPulauPage> createState() => _DetailPulauPageState();
}

class _DetailPulauPageState extends State<DetailPulauPage> {
  final WilayahRepository _wilayahRepository = WilayahRepository();

  RingkasanPulau? _ringkasan;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _muatData();
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
          pulau.nama,
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
                        imagePath: pulau.gambar,
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

                // judul
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GUGUS PULAU',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                          color: AppColors.primaryDark,
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

                // kartu jumlah provinsi & total arsip
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
                            nilai: ringkasan == null
                                ? '—'
                                : '${ringkasan.total}',
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

                if (pulau.deskripsi.isNotEmpty)
                  DetailSectionBlock(
                    title: 'Tentang Pulau',
                    content: pulau.deskripsi,
                  ),

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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
      ),
    );
  }
}
