import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/section_header.dart';

class PilihanDestinasiList extends StatefulWidget {
  const PilihanDestinasiList({super.key});

  @override
  State<PilihanDestinasiList> createState() => _PilihanDestinasiListState();
}

class _PilihanDestinasiListState extends State<PilihanDestinasiList> {
  final ScrollController _scrollController = ScrollController();

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
          child: ScrollbarTheme(
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
                    children: List.generate(5, (index) {
                      return Padding(
                        padding: EdgeInsets.only(right: index < 4 ? 20 : 0),
                        child: _buildDestinationCard(),
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

  Widget _buildDestinationCard() {
    const double itemWidth = 340;
    return Container(
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
                  Image.asset(
                    'assets/images/borobudurB.jpg',
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
                  'Candi Borobudur',
                  style: AppTypography.headingMedium(color: Colors.white),
                ),
                Text(
                  'Jawa Tengah',
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
    );
  }
}
