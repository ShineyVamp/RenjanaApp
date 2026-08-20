import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/extensions/navigation.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../data/local/budaya_kategori.dart';
import '../../../../data/models/budaya_model.dart';
import '../../../../data/repositories/budaya_repository.dart';
import '../../koleksi/koleksi_kategori_page.dart';

/// Daftar delapan kategori budaya. Gambar dan jumlah item pada tiap kartu
/// diambil dari data budaya yang tersimpan di database.
class KoleksiBudayaList extends StatefulWidget {
  const KoleksiBudayaList({super.key});

  @override
  State<KoleksiBudayaList> createState() => _KoleksiBudayaListState();
}

class _KoleksiBudayaListState extends State<KoleksiBudayaList> {
  final ScrollController _scrollController = ScrollController();
  final BudayaRepository _budayaRepository = BudayaRepository();

  Map<String, List<BudayaModel>> _grouped = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final grouped = await _budayaRepository.getBudayaGroupedByJenis();
    if (!mounted) return;
    setState(() {
      _grouped = grouped;
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
        // Number Watermark
        Text(
          '03',
          style: AppTypography.headingLarge(
            color: AppColors.borderPrimary,
          ).copyWith(fontSize: 90, height: 1),
        ),
        const SectionHeader(
          title: 'Koleksi Budaya',
          dividerWidth: 100,
          isCenter: true,
        ),
        const SizedBox(height: 20),

        // Horizontal Scroll Cards
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
                          children: List.generate(
                            budayaKategoriList.length,
                            (index) {
                              final kategori = budayaKategoriList[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: index < budayaKategoriList.length - 1
                                      ? 20
                                      : 0,
                                ),
                                child: _buildCategoryCard(kategori),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(BudayaKategori kategori) {
    const double itemWidth = 340;
    final items = _grouped[kategori.kode] ?? const <BudayaModel>[];
    final coverImage = items.isNotEmpty ? items.first.gambarUtama : null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        await context.push(KoleksiKategoriPage(kategori: kategori));
        await _loadItems();
      },
      child: Container(
        width: itemWidth,
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
                      Colors.black.withAlpha(50),
                      Colors.black.withAlpha(200),
                    ],
                    stops: const [0.4, 0.7, 1.0],
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
                  Text(
                    kategori.nama,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.headingMedium(color: Colors.white),
                  ),
                  Text(
                    '${items.length} koleksi',
                    style: AppTypography.bodyMedium(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Jelajahi lebih lanjut',
                        style: AppTypography.labelBold(color: AppColors.primary),
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
