import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/extensions/navigation.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../data/models/budaya_model.dart';
import '../../../../data/repositories/budaya_repository.dart';
import '../../detail/detail_budaya_page.dart';

/// Budaya yang sekaligus dapat dikunjungi sebagai tempat wisata,
/// ditandai suffix `-D` pada ID tag (mis. `BUD-RMH-1-D`).
class PilihanDestinasiList extends StatefulWidget {
  const PilihanDestinasiList({super.key});

  @override
  State<PilihanDestinasiList> createState() => _PilihanDestinasiListState();
}

class _PilihanDestinasiListState extends State<PilihanDestinasiList> {
  final ScrollController _scrollController = ScrollController();
  final BudayaRepository _budayaRepository = BudayaRepository();

  List<BudayaModel> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final list = await _budayaRepository.getDestinasiList();
    if (!mounted) return;
    setState(() {
      _items = list;
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
          '04',
          style: AppTypography.headingLarge(
            color: AppColors.borderPrimary,
          ).copyWith(fontSize: 90, height: 1),
        ),
        const SectionHeader(
          title: 'Pilihan Destinasi',
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
              : _items.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderPrimary),
                      ),
                      child: Text(
                        'Belum ada destinasi. Tandai koleksi budaya sebagai '
                        'destinasi lewat menu admin untuk menampilkannya di sini.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium(),
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
                              children: List.generate(_items.length, (index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    right: index < _items.length - 1 ? 20 : 0,
                                  ),
                                  child: _buildDestinationCard(_items[index]),
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

  Widget _buildDestinationCard(BudayaModel item) {
    const double itemWidth = 340;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        await context.push(DetailBudayaPage(budaya: item));
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
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppImageView(
                      imagePath: item.gambarUtama,
                      fit: BoxFit.cover,
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
                  ],
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
                    item.judul,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.headingMedium(color: Colors.white),
                  ),
                  Text(
                    item.namaKategoriBudaya,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
