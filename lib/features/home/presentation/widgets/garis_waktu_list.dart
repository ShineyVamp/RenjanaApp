import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/katalog_kategori.dart';
import '../../../../core/extensions/navigation.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/teks_muat.dart';
import '../../../sejarah/data/models/sejarah_model.dart';
import '../../../sejarah/data/repositories/sejarah_repository.dart';
import '../../../sejarah/presentation/arsip_periode_page.dart';

// Garis Waktu Nusantara: daftar sembilan era sejarah Indonesia,
// gambar dan jumlah arsip diambil secara dinamis dari database.
class GarisWaktuList extends StatefulWidget {
  const GarisWaktuList({super.key});

  @override
  State<GarisWaktuList> createState() => _GarisWaktuListState();
}

class _GarisWaktuListState extends State<GarisWaktuList> {
  final ScrollController _scrollController = ScrollController();
  final SejarahRepository _sejarahRepository = SejarahRepository();

  Map<String, List<SejarahModel>> _grouped = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final all = await _sejarahRepository.getAllSejarah();
    final Map<String, List<SejarahModel>> map = {};
    for (final s in all) {
      if (s.periode != null && s.periode!.isNotEmpty) {
        final key = s.periode!.trim().toUpperCase();
        map.putIfAbsent(key, () => []).add(s);
      }
    }
    if (!mounted) return;
    setState(() {
      _grouped = map;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // nomor watermark
        Text(
          '03',
          style: AppTypography.headingLarge(
            color: AppColors.borderPrimary,
          ).copyWith(fontSize: 90, height: 1),
        ),
        const SectionHeader(
          title: 'Garis Waktu Nusantara',
          dividerWidth: 100,
          isCenter: true,
        ),
        const SizedBox(height: 20),

        // kartu era periode, scroll horizontal
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _isLoading
              ? const SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              : ScrollbarTheme(
                  data: const ScrollbarThemeData(
                    thumbColor: WidgetStatePropertyAll(AppColors.primary),
                  ),
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    scrollbarOrientation: ScrollbarOrientation.bottom,
                    thickness: 4,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(periodeSejarahList.length, (
                            index,
                          ) {
                            final periode = periodeSejarahList[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                right: index < periodeSejarahList.length - 1
                                    ? 20
                                    : 0,
                              ),
                              child: _buildEraCard(periode),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEraCard(KategoriItem periode) {
    const double itemWidth = 340;
    final items = _grouped[periode.kode.toUpperCase()] ?? const <SejarahModel>[];
    final coverImage = items.isNotEmpty ? items.first.gambarUtama : 'assets/images/170845history.png';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        await context.push(ArsipPeriodePage(periode: periode));
        await _loadItems();
      },
      child: Container(
        width: itemWidth,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderPrimary),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 8),
              ),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: AppImageView(imagePath: coverImage, fit: BoxFit.cover),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(60),
                      Colors.black.withAlpha(220),
                    ],
                    stops: const [0.35, 0.65, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TeksMuat(
                    teks: periode.nama,
                    gaya: AppTypography.headingMedium(color: Colors.white),
                    ambangKata: 3,
                    ukuranMinimum: 17,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${items.length} arsip sejarah',
                    style: AppTypography.bodyMedium(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Jelajahi era ini',
                        style: AppTypography.labelBold(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
