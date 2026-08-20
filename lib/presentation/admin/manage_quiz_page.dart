import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/extensions/navigation.dart';
import '../../../core/widgets/app_image.dart';
import '../../../data/models/quiz_model.dart';
import '../../../data/repositories/quiz_repository.dart';
import 'admin_quiz_theme_detail_page.dart';
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

  final List<String> _categories = ['SEMUA', 'SEJARAH', 'BUDAYA', 'KEDAERAHAN'];

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

  List<_AdminThemeGroup> get _themeGroups {
    final Map<String, List<QuizSQLModel>> grouped = {};
    for (final q in _quizList) {
      if (q.tema.trim().isEmpty) continue;
      grouped.putIfAbsent(q.tema, () => []).add(q);
    }

    final List<_AdminThemeGroup> groups = grouped.entries.map((e) {
      final first = e.value.first;
      String? coverImage = first.gambar;
      for (final q in e.value) {
        if (q.gambar != null && q.gambar!.trim().isNotEmpty) {
          coverImage = q.gambar;
          break;
        }
      }
      return _AdminThemeGroup(
        tema: e.key,
        kategori: first.kategori,
        coverImage: coverImage,
        questions: e.value,
      );
    }).toList();

    return groups.where((g) {
      final matchesCategory =
          _selectedCategory == 'SEMUA' ||
          g.kategori.toUpperCase() == _selectedCategory.toUpperCase();
      final matchesQuery =
          _searchQuery.isEmpty ||
          g.tema.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          g.kategori.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  void _showAddThemeDialog() {
    final kategoriController = TextEditingController(text: 'SEJARAH');
    final temaController = TextEditingController();
    final soalController = TextEditingController();
    final penjelasanController = TextEditingController();

    final answerControllers = List.generate(
      4,
      (index) => TextEditingController(),
    );
    int selectedCorrectIndex = 0;
    String? selectedImage;

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalContext).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(modalContext).size.height * 0.88,
                ),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tambah Tema & Kuis Baru',
                              style: GoogleFonts.dmSerifDisplay(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () => Navigator.pop(modalContext),
                            ),
                          ],
                        ),
                        const Divider(color: AppColors.primary),
                        const SizedBox(height: 12),

                        // pilihan kategori
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
                              [
                                'SEJARAH',
                                'BUDAYA',
                                'KEDAERAHAN',
                              ].contains(kategoriController.text)
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

                        // input nama tema
                        Text(
                          'Nama Tema Kuis',
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
                              ? 'Nama tema tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 14),

                        // input soal pertama
                        Text(
                          'Soal Pertama',
                          style: AppTypography.labelBold(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: soalController,
                          maxLines: 2,
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

                        // input pilihan jawaban
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
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: const BorderSide(
                                              color: AppColors.border,
                                            ),
                                          ),
                                        ),
                                        validator: (val) =>
                                            val == null || val.trim().isEmpty
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

                        // input penjelasan
                        Text(
                          'Penjelasan / Pembahasan Soal (Opsional)',
                          style: AppTypography.labelBold(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: penjelasanController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Penjelasan mengapa jawaban benar...',
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
                        ),
                        const SizedBox(height: 16),

                        // pemilih gambar
                        AppImagePickerWidget(
                          label: 'Gambar Cover / Soal (Opsional)',
                          isRequired: false,
                          currentImagePath: selectedImage,
                          onImageSelected: (path) {
                            setModalState(() => selectedImage = path);
                          },
                        ),
                        const SizedBox(height: 24),

                        // tombol simpan
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
                                kategori: kategoriController.text.trim(),
                                tema: temaController.text.trim(),
                                soal: soalController.text.trim(),
                                daftarJawaban: answers,
                                jawabanBenar: selectedCorrectIndex,
                                gambar: selectedImage,
                                penjelasan:
                                    penjelasanController.text.trim().isNotEmpty
                                    ? penjelasanController.text.trim()
                                    : null,
                              );

                              final success = await _quizRepository.tambahQuiz(
                                model,
                              );

                              if (!mounted) return;
                              if (modalContext.mounted) {
                                Navigator.pop(modalContext);
                              }

                              final messenger = ScaffoldMessenger.of(context);
                              messenger.clearSnackBars();
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? 'Tema dan kuis berhasil dibuat!'
                                        : 'Gagal membuat kuis.',
                                  ),
                                  duration: const Duration(milliseconds: 1500),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: success
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              );

                              _loadQuizzes();
                            },
                            child: Text(
                              'Buat Tema Kuis',
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

  void _showEditThemeDialog(_AdminThemeGroup group) {
    final kategoriController = TextEditingController(
      text: group.kategori.toUpperCase(),
    );
    final temaController = TextEditingController(text: group.tema);
    String? selectedImage = group.coverImage;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalContext).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Edit Tema & Cover',
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(modalContext),
                          ),
                        ],
                      ),
                      const Divider(color: AppColors.primary),
                      const SizedBox(height: 12),

                      // pilihan kategori
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
                            [
                              'SEJARAH',
                              'BUDAYA',
                              'KEDAERAHAN',
                            ].contains(kategoriController.text.toUpperCase())
                            ? kategoriController.text.toUpperCase()
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

                      // input nama tema
                      Text(
                        'Nama Tema Kuis',
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
                            ? 'Nama tema tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // pemilih gambar sampul
                      AppImagePickerWidget(
                        label: 'Gambar Cover Tema Kuis',
                        isRequired: false,
                        currentImagePath: selectedImage,
                        onImageSelected: (path) {
                          setModalState(() => selectedImage = path);
                        },
                      ),
                      const SizedBox(height: 24),

                      // tombol simpan
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

                            final newTema = temaController.text.trim();
                            final newKategori = kategoriController.text.trim();

                            final success = await _quizRepository
                                .updateThemeInfo(
                                  oldTema: group.tema,
                                  newTema: newTema,
                                  newKategori: newKategori,
                                  newCoverImage: selectedImage,
                                );

                            if (!mounted) return;
                            if (modalContext.mounted) {
                              Navigator.pop(modalContext);
                            }

                            final messenger = ScaffoldMessenger.of(context);
                            messenger.clearSnackBars();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Tema kuis & cover berhasil diperbarui!'
                                      : 'Gagal memperbarui tema.',
                                ),
                                duration: const Duration(milliseconds: 1500),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: success
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            );

                            _loadQuizzes();
                          },
                          child: Text(
                            'Simpan Perubahan Tema',
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
            );
          },
        );
      },
    );
  }

  void _confirmDeleteTheme(_AdminThemeGroup group) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Tema Kuis?',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Seluruh ${group.questions.length} soal dalam tema "${group.tema}" akan dihapus permanen.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await _quizRepository.deleteQuizzesByTema(group.tema);
              if (!mounted) return;
              final messenger = ScaffoldMessenger.of(context);
              messenger.clearSnackBars();
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Tema kuis berhasil dihapus'),
                  duration: Duration(milliseconds: 1500),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.success,
                ),
              );
              _loadQuizzes();
            },
            child: Text(
              'Hapus Tema',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groups = _themeGroups;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Kelola Kuis',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _loadQuizzes,
          ),
        ],
        shape: const Border(
          bottom: BorderSide(color: AppColors.primary, width: 0.8),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // kotak pencarian
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari tema kuis...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.borderLight,
                        ),
                      ),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                  const SizedBox(height: 14),

                  // chip filter kategori
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.surface,
                            labelStyle: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
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
                                setState(() => _selectedCategory = cat);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daftar Tema Kuis',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${groups.length} Tema',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (groups.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.quiz_outlined,
                              size: 40,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Belum ada tema kuis ditemukan.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      children: groups.map((group) {
                        return _buildThemeCard(group);
                      }).toList(),
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Tambah Tema',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        onPressed: _showAddThemeDialog,
      ),
    );
  }

  Widget _buildThemeCard(_AdminThemeGroup group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header kartu, area kliknya dipisah dari body
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    group.kategori.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${group.questions.length} Soal',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),

                // tombol edit tema & sampul
                Material(
                  color: Colors.blue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () => _showEditThemeDialog(group),
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            color: Colors.blueAccent,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // tombol hapus tema
                Material(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () => _confirmDeleteTheme(group),
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Hapus',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // body kartu, membuka daftar soal tema ini
          Material(
            color: Colors.transparent,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(12),
            ),
            child: InkWell(
              onTap: () async {
                await context.push(
                  AdminQuizThemeDetailPage(
                    tema: group.tema,
                    kategori: group.kategori,
                  ),
                );
                _loadQuizzes();
              },
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    if (group.coverImage != null &&
                        group.coverImage!.trim().isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 80,
                          height: 70,
                          child: AppImageView(
                            imagePath: group.coverImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.tema,
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Klik untuk mengelola atau mengedit soal di tema ini.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminThemeGroup {
  final String tema;
  final String kategori;
  final String? coverImage;
  final List<QuizSQLModel> questions;

  _AdminThemeGroup({
    required this.tema,
    required this.kategori,
    this.coverImage,
    required this.questions,
  });
}
