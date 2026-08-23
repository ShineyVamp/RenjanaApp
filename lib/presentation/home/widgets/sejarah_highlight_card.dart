import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/extensions/navigation.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/models/sejarah_model.dart';
import '../../detail/detail_sejarah_page.dart';

class SejarahHighlightCard extends StatelessWidget {
  final SejarahModel data;

  const SejarahHighlightCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // nomor watermark
        Positioned(
          right: -15,
          top: -40,
          child: Text(
            '01',
            style: AppTypography.headingLarge(
              color: AppColors.borderPrimary,
            ).copyWith(fontSize: 90),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionBadgeTitle(title: 'Sejarah Hari Ini'),
            const SizedBox(height: 20),

            // gambar dengan bingkai miring dan ID tag
            Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Transform.rotate(
                      angle: -1 * (math.pi / 180),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white,
                            strokeAlign: BorderSide.strokeAlignOutside,
                            width: 5,
                          ),
                        ),
                        child: AppImageView(
                          imagePath: data.gambarUtama,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -10,
                  right: 0,
                  child: Container(
                    color: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    child: Text(data.kodeTag, style: AppTypography.tag()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ringkasan
            Text(
              data.judul,
              style: AppTypography.headingLarge(
                color: AppColors.textPrimary,
              ).copyWith(fontSize: 34, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 4),
            Container(width: 120, height: 1.5, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              data.ringkasan,
              style: AppTypography.bodyMedium(),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),

            // tombol baca selengkapnya
            AppButton(
              text: 'Masuki Kisah',
              borderRadius: 6,
              onPressed: () {
                context.push(DetailSejarahPage(sejarah: data));
              },
            ),
          ],
        ),
      ],
    );
  }
}
