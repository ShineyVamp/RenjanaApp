import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../data/models/quiz_model.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({super.key});

  // Kategori data
  static const List<String> _categories = [
    'Sejarah',
    'Budaya',
    'Kedaerahan',
  ];

  static const List<String> _categoryImages = [
    'assets/images/170845history.png',
    'assets/images/borobudurB.jpg',
    'assets/images/onboardin1.jpg',
  ];

  // Rekomendasi kuis menggunakan QuizSQLModel
  static final List<QuizSQLModel> _recommendations = [
    QuizSQLModel(
      kategori: 'SEJARAH',
      tema: 'Perjalanan\nRevolusi',
      soal: 'Uji kemampuan anda tentang perjalanan revolusi indonesia',
      daftarJawaban: const [],
      jawabanBenar: 0,
      gambar: 'assets/images/rengasdengklok.jpg',
    ),
    QuizSQLModel(
      kategori: 'BUDAYA',
      tema: 'Budaya\nSulawesi\nSelatan',
      soal: 'Uji kemampuan anda tentang budaya sulawesi selatan',
      daftarJawaban: const [],
      jawabanBenar: 0,
      gambar: 'assets/images/borobudurB.jpg',
    ),
    QuizSQLModel(
      kategori: 'KEDAERAHAN',
      tema: 'Kekayaan\nSulawesi\nSelatan',
      soal: 'Uji kemampuan anda tentang kekayaan daerah Sulawesi Selatan',
      daftarJawaban: const [],
      jawabanBenar: 0,
      gambar: 'assets/images/onboardin2.jpg',
    ),
  ];

  static const List<String> _totalQuestions = [
    '15 SOAL',
    '10 SOAL',
    '10 SOAL',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/Rlogos.png', width: 28, height: 28),
            const SizedBox(width: 8),
            Text(
              'RENJANA',
              style: AppTypography.brandTitle(color: AppColors.textPrimary),
            ),
          ],
        ),
        shape: const Border(
          bottom: BorderSide(color: AppColors.primary, width: 0.8),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Kuis
            Text(
              'Kuis',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 2.5,
              width: 90,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),

            // Kategori
            Text(
              'Kategori',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),

            // Card Kategori menggunakan List.generate
            Column(
              children: List.generate(_categories.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _QuizCategoryCard(
                    title: _categories[index],
                    imagePath: _categoryImages[index],
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Kategori: ${_categories[index]}'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            // Rekomendasi Kuis
            Text(
              'Rekomendasi Kuis',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Rekomendasi Kuis menggunakan List.generate & QuizSQLModel
            Column(
              children: List.generate(_recommendations.length, (index) {
                final quiz = _recommendations[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _QuizRecommendationCard(
                    quiz: quiz,
                    imagePath: quiz.gambar,
                    totalQuestions: _totalQuestions[index],
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Mulai kuis: ${quiz.tema.replaceAll('\n', ' ')}',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card Widgets (Diletakkan dalam 1 file)
// ---------------------------------------------------------------------------

class _QuizCategoryCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback? onTap;

  const _QuizCategoryCard({
    required this.title,
    required this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 82,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withOpacity(0.75),
                      Colors.black.withOpacity(0.25),
                    ],
                  ),
                ),
              ),

              // Title Text
              Positioned(
                left: 18,
                bottom: 14,
                child: Text(
                  title,
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizRecommendationCard extends StatelessWidget {
  final QuizSQLModel quiz;
  final String? imagePath;
  final String totalQuestions;
  final VoidCallback? onTap;

  const _QuizRecommendationCard({
    required this.quiz,
    this.imagePath,
    this.totalQuestions = '10 SOAL',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayImage = imagePath ?? quiz.gambar ?? 'assets/images/rengasdengklok.jpg';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 165,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Image
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                  child: SizedBox(
                    width: 125,
                    child: Image.asset(
                      displayImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Right Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Tag
                        Text(
                          quiz.kategori.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Title / Tema
                        Text(
                          quiz.tema,
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            height: 1.15,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),

                        // Description / Soal
                        Text(
                          quiz.soal,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const Spacer(),

                        // Footer (Total Questions)
                        Text(
                          totalQuestions,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
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
