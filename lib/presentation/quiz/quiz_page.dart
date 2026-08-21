import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/extensions/navigation.dart';
import '../../core/widgets/app_image.dart';
import '../../data/models/quiz_model.dart';
import '../../data/repositories/quiz_repository.dart';
import 'quiz_play_page.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final QuizRepository _quizRepository = QuizRepository();
  List<QuizSQLModel> _allQuizzes = [];
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

  final ScrollController _scrollRekomendasi = ScrollController();

  // tempat naruh rekomendasi kuis biar gak ilang kalo di refresh
  List<String> _recommendedThemes = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollRekomendasi.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool showLoader = true}) async {
    if (showLoader) setState(() => _isLoading = true);
    final list = await _quizRepository.getAllQuizzes();
    if (!mounted) return;
    setState(() {
      _allQuizzes = list;
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

  void _shuffleRecommendations() {
    setState(() => _recommendedThemes = _pickRandomThemes());
    if (_scrollRekomendasi.hasClients) {
      _scrollRekomendasi.jumpTo(0);
    }
  }

  // Soal dikelompokkan per tema, lalu diambil sesuai tema yang sedang terpilih.
  List<_ThemeRecommendation> get _themeRecommendations {
    final Map<String, List<QuizSQLModel>> grouped = {};
    for (final q in _allQuizzes) {
      final tema = q.tema.trim();
      if (tema.isEmpty) continue;
      grouped.putIfAbsent(tema, () => []).add(q);
    }

    final result = <_ThemeRecommendation>[];
    for (final tema in _recommendedThemes) {
      final soalList = grouped[tema];
      if (soalList == null || soalList.isEmpty) continue;

      final first = soalList.first;
      String coverImage = first.gambar ?? '';
      for (final q in soalList) {
        if (q.gambar != null && q.gambar!.trim().isNotEmpty) {
          coverImage = q.gambar!;
          break;
        }
      }
      result.add(
        _ThemeRecommendation(
          tema: tema,
          kategori: first.kategori,
          coverImage: coverImage,
          questionCount: soalList.length,
          sampleQuestion: first.soal,
          questions: soalList,
        ),
      );
    }
    return result;
  }

  // Kartu dipecah per kolom berisi 3 baris; kolom berikutnya diakses
  // dengan menggeser ke samping.
  List<Widget> _buildRecommendationColumns(List<_ThemeRecommendation> items) {
    final columns = <Widget>[];
    for (int start = 0; start < items.length; start += _recommendationRows) {
      final chunk = items.skip(start).take(_recommendationRows).toList();
      final isLastColumn = start + _recommendationRows >= items.length;

      columns.add(
        Padding(
          padding: EdgeInsets.only(right: isLastColumn ? 0 : 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(chunk.length, (i) {
              return Padding(
                padding: EdgeInsets.only(bottom: i < chunk.length - 1 ? 16 : 0),
                child: SizedBox(
                  width: _recommendationCardWidth,
                  height: _recommendationCardHeight,
                  child: _QuizRecommendationCard(
                    recommendation: chunk[i],
                    onTap: () => _startThemeQuiz(chunk[i]),
                  ),
                ),
              );
            }),
          ),
        ),
      );
    }
    return columns;
  }

  void _showCategoryQuizModal(String categoryName) async {
    final availableCount = await _quizRepository.getQuizCountByKategori(
      categoryName,
    );
    if (!mounted) return;

    int selectedCount = availableCount > 0
        ? (availableCount < 10 ? availableCount : 10)
        : 10;
    final customController = TextEditingController(text: '$selectedCount');
    bool isCustom = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kuis Kategori',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            categoryName.toUpperCase(),
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(modalCtx),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.primary),
                  const SizedBox(height: 12),

                  Text(
                    'Soal akan dipilih secara acak (random) dari berbagai tema dalam kategori $categoryName.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Total bank soal tersedia: $availableCount soal',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  Text(
                    'Pilih Jumlah Soal yang Ingin Dikerjakan:',
                    style: AppTypography.labelBold(fontSize: 13),
                  ),
                  const SizedBox(height: 10),

                  // pilihan jumlah soal cepat
                  Wrap(
                    spacing: 10,
                    children: [10, 20, 50].map((count) {
                      final isSelected = !isCustom && selectedCount == count;
                      return ChoiceChip(
                        label: Text('$count Soal'),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.borderLight,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() {
                              isCustom = false;
                              selectedCount = count;
                              customController.text = '$count';
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // input jumlah soal manual
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: customController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Atau Masukkan Jumlah Sendiri',
                            hintText: 'Misal: 5, 15, 25',
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                              ),
                            ),
                          ),
                          onChanged: (val) {
                            final parsed = int.tryParse(val.trim());
                            if (parsed != null && parsed > 0) {
                              setModalState(() {
                                isCustom = true;
                                selectedCount = parsed;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // tombol mulai
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        final inputVal =
                            int.tryParse(customController.text.trim()) ??
                            selectedCount;
                        final targetCount = inputVal > 0 ? inputVal : 10;

                        Navigator.pop(modalCtx);

                        final questions = await _quizRepository
                            .getRandomQuizzesByCategory(
                              categoryName,
                              targetCount,
                            );

                        if (!mounted) return;

                        if (questions.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Belum ada soal untuk kategori $categoryName.',
                              ),
                              backgroundColor: AppColors.primaryDark,
                            ),
                          );
                          return;
                        }

                        context.push(
                          QuizPlayPage(
                            title: 'Kuis $categoryName',
                            category: categoryName,
                            questions: questions,
                          ),
                        );
                      },
                      child: Text(
                        'Mulai Kuis ($selectedCount Soal)',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _startThemeQuiz(_ThemeRecommendation rec) {
    if (rec.questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Belum ada soal untuk tema ini.'),
          backgroundColor: AppColors.primaryDark,
        ),
      );
      return;
    }

    final shuffled = List<QuizSQLModel>.from(rec.questions)..shuffle();

    context.push(
      QuizPlayPage(
        title: rec.tema,
        category: rec.kategori,
        questions: shuffled,
      ),
    );
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
        appBar: AppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
          title: Row(
            mainAxisAlignment: .start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/Rlogos.png', width: 32, height: 32),
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
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : RefreshIndicator(
                color: AppColors.primary,
                // loader halaman dimatikan supaya grid rekomendasi tidak
                // ikut hilang-muncul saat tarik-refresh
                onRefresh: () => _loadData(showLoader: false),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        children: List.generate(_categories.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _QuizCategoryCard(
                              title: _categories[index],
                              imagePath: _categoryImages[index],
                              onTap: () =>
                                  _showCategoryQuizModal(_categories[index]),
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

                          // acak ulang isi grid, tidak ikut RefreshIndicator halaman
                          IconButton(
                            onPressed: recommendations.isEmpty
                                ? null
                                : _shuffleRecommendations,
                            icon: const Icon(Icons.refresh_rounded, size: 20),
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
                            border: Border.all(color: AppColors.borderLight),
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
                        ScrollbarTheme(
                          data: const ScrollbarThemeData(
                            thumbColor: WidgetStatePropertyAll(
                              AppColors.primary,
                            ),
                          ),
                          child: Scrollbar(
                            controller: _scrollRekomendasi,
                            thumbVisibility: true,
                            trackVisibility: true,
                            scrollbarOrientation: ScrollbarOrientation.bottom,
                            thickness: 4,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: SingleChildScrollView(
                                controller: _scrollRekomendasi,
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _buildRecommendationColumns(
                                    recommendations,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _ThemeRecommendation {
  final String tema;
  final String kategori;
  final String coverImage;
  final int questionCount;
  final String sampleQuestion;
  final List<QuizSQLModel> questions;

  _ThemeRecommendation({
    required this.tema,
    required this.kategori,
    required this.coverImage,
    required this.questionCount,
    required this.sampleQuestion,
    required this.questions,
  });
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

class _QuizRecommendationCard extends StatelessWidget {
  final _ThemeRecommendation recommendation;
  final VoidCallback? onTap;

  const _QuizRecommendationCard({required this.recommendation, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // gambar tema
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
                child: SizedBox(
                  width: 130,
                  child: AppImageView(
                    imagePath: recommendation.coverImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // deskripsi tema
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            recommendation.tema,
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),

                          Text(
                            recommendation.sampleQuestion,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${recommendation.questionCount} SOAL',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Mulai',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
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
