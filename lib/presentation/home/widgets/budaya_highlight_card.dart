import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/extensions/navigation.dart';
import '../../../../core/widgets/section_header.dart';
import '../../detail/detail_budaya_page.dart';

class BudayaHighlightCard extends StatelessWidget {
  const BudayaHighlightCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title Tag on Right
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            SectionBadgeTitle(title: 'Budaya Hari Ini'),
          ],
        ),
        const SizedBox(height: 16),

        // Content Card with 02 Watermark
        Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -80,
              left: -15,
              child: Text(
                '02',
                style: AppTypography.headingLarge(
                  color: AppColors.borderPrimary,
                ).copyWith(fontSize: 90),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            spreadRadius: -4,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/kerisB.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    color: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    child: Text(
                      'BUD-SNJT-1',
                      style: AppTypography.tag(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Q-RIS',
                    style: AppTypography.headingMedium(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lebih dari sekadar senjata, keris adalah mahakarya seni tempa, perwujudan doa, dan simbol identitas kultural yang mendalam. Pola pamornya mengisahkan filsafat alam semesta.',
                    style: AppTypography.bodyMedium(),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      context.push(const DetailBudayaPage());
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Pelajari lebih lanjut',
                          style: AppTypography.labelBold(
                            color: AppColors.primary,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
