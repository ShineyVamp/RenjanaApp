import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/extensions/navigation.dart';
import '../../../core/widgets/app_image.dart';
import '../../../data/models/quiz_model.dart';
import '../../../data/repositories/quiz_repository.dart';
import 'widgets/app_image_picker_widget.dart';

class AdminManageQuizPage extends StatefulWidget {
  const AdminManageQuizPage({super.key});

  @override
  State<AdminManageQuizPage> createState() => _AdminManageQuizPageState();
}

class _AdminManageQuizPageState extends State<AdminManageQuizPage> {
  final QuizRepository _quizRepository = QuizRepository();
  List<QuizSQLModel> _quizList = [];
  bool _isLoading = true;
  String _selectedCategory = 'SEMUA';
  String _searchQuery = '';

  final List<String> _categories = [
    'SEMUA',
    'SEJARAH',
    'BUDAYA',
    'KEDAERAHAN',
  ];

  final List<String> _availableImages = [
    'assets/images/170845history.png',
    'assets/images/rengasdengklok.jpg',
    'assets/images/1308history.png',
    'assets/images/borobudurB.jpg',
    'assets/images/kerisB.jpg',
    'assets/images/onboardin1.jpg',
    'assets/images/onboardin2.jpg',
    'assets/images/onboardin3.jpg',
    'assets/images/perumusan.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    setState(() => _isLoading = true);
    final list = await _quizRepository.getAllQuizzes();
    if (!mounted) return;
    setState(() {
      _quizList = list;
      _isLoading = false;
    });
  }

  List<QuizSQLModel> get _filteredList {
    return _quizList.where((quiz) {
      final matchesCategory = _selectedCategory == 'SEMUA' ||
          quiz.kategori.toUpperCase() == _selectedCategory.toUpperCase();
      final matchesQuery = _searchQuery.isEmpty ||
          quiz.tema.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          quiz.soal.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  void _showQuizFormDialog({QuizSQLModel? quizToEdit}) {
    final isEditing = quizToEdit != null;
    final kategoriController = TextEditingController(
      text: isEditing ? quizToEdit.kategori : 'SEJARAH',
    );
    final temaController = TextEditingController(
      text: isEditing ? quizToEdit.tema : '',
    );
    final soalController = TextEditingController(
      text: isEditing ? quizToEdit.soal : '',
    );

    // Initial 4 answers
    List<String> currentAnswers = isEditing && quizToEdit.daftarJawaban.isNotEmpty
        ? List<String>.from(quizToEdit.daftarJawaban)
        : ['', '', '', ''];
    while (currentAnswers.length < 4) {
      currentAnswers.add('');
    }

    final answerControllers = currentAnswers
        .map((ans) => TextEditingController(text: ans))
        .toList();

    int selectedCorrectIndex = isEditing ? quizToEdit.jawabanBenar : 0;
    String selectedImage = isEditing && quizToEdit.gambar != null
        ? quizToEdit.gambar!
        : _availableImages.first;

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalContext).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(modalContext).size.height * 0.85,
                ),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isEditing ? 'Edit Kuis' : 'Tambah Kuis Baru',
                              style: GoogleFonts.dmSerifDisplay(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(modalContext),
                            ),
                          ],
                        ),
                        const Divider(color: AppColors.primary),
                        const SizedBox(height: 12),

                        // Kategori
                        Text(
                          'Kategori',
                          style: AppTypography.labelBold(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue:
                              _categories.contains(kategoriController.text) &&
                                      kategoriController.text != 'SEMUA'
                                  ? kategoriController.text
                                  : 'SEJARAH',
                          decoration: InputDecoration(
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
                          items: ['SEJARAH', 'BUDAYA', 'KEDAERAHAN']
                              .map(
                                (kat) => DropdownMenuItem(
                                  value: kat,
                                  child: Text(kat),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() {
                                kategoriController.text = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 14),

                        // Tema / Judul
                        Text(
                          'Tema / Judul Kuis',
                          style: AppTypography.labelBold(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: temaController,
                          decoration: InputDecoration(
                            hintText: 'Contoh: Perjalanan Revolusi',
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
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Tema tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 14),

                        // Soal
                        Text(
                          'Pertanyaan / Soal Kuis',
                          style: AppTypography.labelBold(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: soalController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Masukkan pertanyaan soal kuis...',
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
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Soal tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 14),

                        // Pilihan Jawaban
                        Text(
                          'Pilihan Jawaban (Pilih radio untuk jawaban benar)',
                          style: AppTypography.labelBold(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RadioGroup<int>(
                          groupValue: selectedCorrectIndex,
                          onChanged: (val) {
                            setModalState(() {
                              selectedCorrectIndex = val ?? 0;
                            });
                          },
                          child: Column(
                            children: List.generate(4, (i) {
                              final labels = ['A', 'B', 'C', 'D'];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Radio<int>(
                                      value: i,
                                      activeColor: AppColors.primary,
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        controller: answerControllers[i],
                                        decoration: InputDecoration(
                                          labelText: 'Pilihan ${labels[i]}',
                                          filled: true,
                                          fillColor: AppColors.surface,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                              color: AppColors.border,
                                            ),
                                          ),
                                        ),
                                        validator: (val) => val == null ||
                                                val.trim().isEmpty
                                            ? 'Pilihan ${labels[i]} wajib diisi'
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 12),

                        AppImagePickerWidget(
                          label: 'Pilih / Upload Cover Kuis',
                          isRequired: true,
                          currentImagePath: selectedImage,
                          onImageSelected: (path) {
                            if (path != null) {
                              setModalState(() => selectedImage = path);
                            }
                          },
                        ),
                        const SizedBox(height: 24),

                        // Action Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) return;

                              final answers = answerControllers
                                  .map((c) => c.text.trim())
                                  .toList();

                              final model = QuizSQLModel(
                                id: isEditing ? quizToEdit.id : null,
                                kategori: kategoriController.text.trim(),
                                tema: temaController.text.trim(),
                                soal: soalController.text.trim(),
                                daftarJawaban: answers,
                                jawabanBenar: selectedCorrectIndex,
                                gambar: selectedImage,
                              );

                              bool success;
                              if (isEditing) {
                                success = await _quizRepository.updateQuiz(model);
                              } else {
                                success = await _quizRepository.tambahQuiz(model);
                              }

                              if (!mounted) return;
                              if (modalContext.mounted) {
                                Navigator.pop(modalContext);
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? (isEditing
                                            ? 'Kuis berhasil diperbarui!'
                                            : 'Kuis berhasil ditambahkan!')
                                        : 'Gagal menyimpan kuis.',
                                  ),
                                  backgroundColor: success
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              );

                              _loadQuizzes();
                            },
                            child: Text(
                              isEditing ? 'Simpan Perubahan' : 'Tambah Kuis',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
          },
        );
      },
    );
  }

  void _confirmDeleteQuiz(QuizSQLModel quiz) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            'Hapus Kuis?',
            style: GoogleFonts.dmSerifDisplay(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus kuis "${quiz.tema}"?',
            style: AppTypography.bodyMedium(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Batal',
                style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                if (quiz.id != null) {
                  final success = await _quizRepository.deleteQuiz(quiz.id!);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Kuis berhasil dihapus'
                            : 'Gagal menghapus kuis',
                      ),
                      backgroundColor:
                          success ? AppColors.success : AppColors.error,
                    ),
                  );
                  _loadQuizzes();
                }
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredList;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Manage Quiz',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 28),
            tooltip: 'Tambah Kuis Baru',
            onPressed: () => _showQuizFormDialog(),
          ),
        ],
        shape: const Border(
          bottom: BorderSide(color: AppColors.primary, width: 0.8),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            color: AppColors.background,
            child: Column(
              children: [
                // Search Field
                TextField(
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari kuis berdasarkan judul / soal...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Category Filter Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                          backgroundColor: AppColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Total Data Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Kuis: ${filtered.length}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Klik edit/hapus pada kartu',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // List of Quizzes
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.quiz_outlined,
                              size: 48,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Belum ada data kuis',
                              style: AppTypography.bodyMedium(),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                              ),
                              onPressed: () => _showQuizFormDialog(),
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text(
                                'Tambah Kuis Pertama',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final quiz = filtered[index];
                          return _buildAdminQuizCard(quiz);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showQuizFormDialog(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Tambah Kuis',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAdminQuizCard(QuizSQLModel quiz) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header inside card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    quiz.kategori.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => _showQuizFormDialog(quizToEdit: quiz),
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.edit_outlined,
                      color: Colors.blueAccent,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () => _confirmDeleteQuiz(quiz),
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tema / Judul
                Text(
                  quiz.tema,
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),

                // Pertanyaan / Soal
                Text(
                  quiz.soal,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (quiz.gambar != null && quiz.gambar!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      height: 110,
                      width: double.infinity,
                      child: AppImageView(
                        imagePath: quiz.gambar,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 10),

                // Options preview
                if (quiz.daftarJawaban.isNotEmpty) ...[
                  Text(
                    'Pilihan Jawaban:',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...List.generate(quiz.daftarJawaban.length, (optIndex) {
                    final isCorrect = optIndex == quiz.jawabanBenar;
                    final labels = ['A', 'B', 'C', 'D'];
                    final label = optIndex < labels.length ? labels[optIndex] : '$optIndex';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Icon(
                            isCorrect
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            size: 14,
                            color: isCorrect
                                ? AppColors.success
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '$label. ${quiz.daftarJawaban[optIndex]}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: isCorrect
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isCorrect
                                    ? AppColors.success
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
