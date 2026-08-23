import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/extensions/navigation.dart';
import '../../core/widgets/grid_horizontal.dart';
import '../../core/widgets/header_halaman.dart';
import '../../core/widgets/kartu_tema_kuis.dart';
import '../../data/models/quiz_model.dart';
import '../../data/models/tema_kuis_model.dart';
import '../../data/repositories/quiz_repository.dart';
import 'kategori_kuis_page.dart';
import 'mulai_kuis.dart';
import 'quiz_play_page.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final QuizRepository _quizRepository = QuizRepository();
  List<QuizSQLModel> _allQuizzes = [];
  int _jumlahSoalSalah = 0;
  bool _isLoading = true;

  static const List<String> _categories = ['Sejarah', 'Budaya', 'Kedaerahan'];

  static const List<String> _categoryImages = [
    'assets/images/170845history.png',
    'assets/images/borobudurB.jpg',
    'assets/images/onboardin1.jpg',
  ];

  // grid rekomendasi: 3 baris ke bawah, 3 kolom ke samping
  static const int _maxRecommendations = 9;
  static const int _recommendationRows = 3;
  static const double _recommendationCardWidth = 350;
  static const double _recommendationCardHeight = 140;

  // nama tema yang sedang direkomendasikan
  List<String> _recommendedThemes = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool showLoader = true}) async {
    if (showLoader) setState(() => _isLoading = true);
    final list = await _quizRepository.getAllQuizzes();
    final salah = await _quizRepository.getJumlahSoalSalah();
    if (!mounted) return;
    setState(() {
      _allQuizzes = list;
      _jumlahSoalSalah = salah;
      _isLoading = false;
      _syncRecommendedThemes();
    });
  }

  // semua nama tema yang punya soal
  List<String> get _allThemes {
    final set = <String>{};
    for (final q in _allQuizzes) {
      final tema = q.tema.trim();
      if (tema.isNotEmpty) set.add(tema);
    }
    return set.toList();
  }

  List<String> _pickRandomThemes() {
    final pool = _allThemes..shuffle();
    return pool.take(_maxRecommendations).toList();
  }

  void _syncRecommendedThemes() {
    final tersedia = _allThemes.toSet();
    _recommendedThemes = _recommendedThemes.where(tersedia.contains).toList();
    if (_recommendedThemes.isEmpty) {
      _recommendedThemes = _pickRandomThemes();
    }
  }

  // Mengacak ulang isi rekomendasi.
  void _shuffleRecommendations() {
    setState(() => _recommendedThemes = _pickRandomThemes());
  }

  // Data tema rekomendasi, urut sesuai hasil pengacakan.
  List<TemaKuis> get _themeRecommendations {
    final semua = {for (final t in TemaKuis.dariSoal(_allQuizzes)) t.tema: t};
    return [
      for (final tema in _recommendedThemes)
        if (semua.containsKey(tema)) semua[tema]!,
    ];
  }

  // Membuka halaman kategori, lalu memuat ulang daftar tema setelah kembali.
  Future<void> _bukaKategori(String kategori) async {
    await context.push(KategoriKuisPage(kategori: kategori));
    if (!mounted) return;
    await _loadData(showLoader: false);
  }

  Future<void> _mulaiLatihanSoalSalah() async {
    final list = await _quizRepository.getSoalSalahList();
    if (list.isEmpty || !mounted) return;
    await context.push(
      QuizPlayPage(
        title: 'Latihan Soal Salah',
        category: 'Latihan',
        questions: list,
      ),
    );
    if (!mounted) return;
    await _loadData(showLoader: false);
  }

  @override
  Widget build(BuildContext context) {
    final recommendations = _themeRecommendations;
    final totalTema = _allThemes.length;
    final labelTema = totalTema > recommendations.length
        ? '${recommendations.length} dari $totalTema Tema'
        : '${recommendations.length} Tema';

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 800),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const HeaderHalaman(judul: 'Kuis', garisBawah: false),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        // tarik-refresh, tanpa loader halaman
                        onRefresh: () => _loadData(showLoader: false),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_jumlahSoalSalah > 0) ...[
                                Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppColors.borderPrimary,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withAlpha(15),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 46,
                                        height: 46,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryDark
                                              .withAlpha(25),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.history_edu_rounded,
                                          color: AppColors.primaryDark,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Bank Soal Salah',
                                              style: GoogleFonts.dmSerifDisplay(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '$_jumlahSoalSalah soal perlu dilatih kembali',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                color:
                                                    AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: _mulaiLatihanSoalSalah,
                                        child: Text(
                                          'Latih',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              Text(
                                'Kategori',
                                style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 14),

                              // section kartu kategori
                              Column(
                                children: List.generate(_categories.length, (
                                  index,
                                ) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _QuizCategoryCard(
                                      title: _categories[index],
                                      imagePath: _categoryImages[index],
                                      onTap: () =>
                                          _bukaKategori(_categories[index]),
                                    ),
                                  );
                                }),
                              ),

                              const SizedBox(height: 24),

                              // section rekomendasi per tema
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Rekomendasi Kuis',
                                      style: GoogleFonts.dmSerifDisplay(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    labelTema,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),

                                  // tombol acak ulang rekomendasi
                                  IconButton(
                                    onPressed: recommendations.isEmpty
                                        ? null
                                        : _shuffleRecommendations,
                                    icon: const Icon(
                                      Icons.refresh_rounded,
                                      size: 20,
                                    ),
                                    color: AppColors.primary,
                                    tooltip: 'Acak ulang rekomendasi',
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              if (recommendations.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.borderLight,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Belum ada tema kuis tersedia.',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                GridHorizontal(
                                  key: ValueKey(_recommendedThemes.join('|')),
                                  jumlahItem: recommendations.length,
                                  baris: _recommendationRows,
                                  lebarKartu: _recommendationCardWidth,
                                  tinggiKartu: _recommendationCardHeight,
                                  builder: (index) => KartuTemaKuis(
                                    tema: recommendations[index],
                                    onTap: () => mulaiKuisTema(
                                      context,
                                      recommendations[index],
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 24),
                            ],
                          ),
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
      borderRadius: BorderRadius.circular(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 150,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(imagePath, fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.black.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 18,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                  ),
                ),
              ),
              const Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 26,
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
