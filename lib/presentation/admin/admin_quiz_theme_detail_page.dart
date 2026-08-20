import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/app_image.dart';
import '../../../data/models/quiz_model.dart';
import '../../../data/repositories/quiz_repository.dart';
import 'widgets/app_image_picker_widget.dart';

class AdminQuizThemeDetailPage extends StatefulWidget {
  final String tema;
  final String kategori;

  const AdminQuizThemeDetailPage({
    super.key,
    required this.tema,
    required this.kategori,
  });

  @override
  State<AdminQuizThemeDetailPage> createState() =>
      _AdminQuizThemeDetailPageState();
}

class _AdminQuizThemeDetailPageState extends State<AdminQuizThemeDetailPage> {
  final QuizRepository _quizRepository = QuizRepository();
  List<QuizSQLModel> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    final list = await _quizRepository.getQuizByTema(widget.tema);
    if (!mounted) return;
    setState(() {
      _questions = list;
      _isLoading = false;
    });
  }

  void _showQuestionFormDialog({QuizSQLModel? questionToEdit}) {
    final isEditing = questionToEdit != null;
    final soalController = TextEditingController(
      text: isEditing ? questionToEdit.soal : '',
    );
    final penjelasanController = TextEditingController(
      text: isEditing ? (questionToEdit.penjelasan ?? '') : '',
    );

    List<String> currentAnswers =
        isEditing && questionToEdit.daftarJawaban.isNotEmpty
        ? List<String>.from(questionToEdit.daftarJawaban)
        : ['', '', '', ''];
    while (currentAnswers.length < 4) {
      currentAnswers.add('');
    }

    final answerControllers = currentAnswers
        .map((ans) => TextEditingController(text: ans))
        .toList();

    int selectedCorrectIndex = isEditing ? questionToEdit.jawabanBenar : 0;
    String? selectedImage = isEditing ? questionToEdit.gambar : null;

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
                        // header modal
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isEditing ? 'Edit Soal' : 'Tambah Soal Baru',
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

                        // info tema
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Tema: ${widget.tema} (${widget.kategori})',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // input pertanyaan
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
                              ? 'Pertanyaan tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // input pilihan jawaban
                        Text(
                          'Pilihan Jawaban (Pilih radio untuk kunci jawaban benar)',
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
                            hintText:
                                'Masukkan penjelasan mengapa jawaban tersebut benar...',
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

                        // pemilih gambar, opsional
                        AppImagePickerWidget(
                          label: 'Gambar Soal (Opsional / Tambahan)',
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
                                id: isEditing ? questionToEdit.id : null,
                                kategori: widget.kategori,
                                tema: widget.tema,
                                soal: soalController.text.trim(),
                                daftarJawaban: answers,
                                jawabanBenar: selectedCorrectIndex,
                                gambar:
                                    (selectedImage != null &&
                                        selectedImage!.trim().isNotEmpty)
                                    ? selectedImage
                                    : null,
                                penjelasan:
                                    penjelasanController.text.trim().isNotEmpty
                                    ? penjelasanController.text.trim()
                                    : null,
                              );

                              bool success;
                              if (isEditing) {
                                success = await _quizRepository.updateQuiz(
                                  model,
                                );
                              } else {
                                success = await _quizRepository.tambahQuiz(
                                  model,
                                );
                              }

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
                                        ? (isEditing
                                              ? 'Soal berhasil diperbarui!'
                                              : 'Soal berhasil ditambahkan!')
                                        : 'Gagal menyimpan soal.',
                                  ),
                                  duration: const Duration(milliseconds: 1500),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: success
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              );

                              _loadQuestions();
                            },
                            child: Text(
                              isEditing ? 'Simpan Perubahan' : 'Tambah Soal',
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

  void _confirmDeleteQuestion(QuizSQLModel question) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Soal?',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus soal ini?',
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
              if (question.id != null) {
                await _quizRepository.deleteQuiz(question.id!);
                if (!mounted) return;
                final messenger = ScaffoldMessenger.of(context);
                messenger.clearSnackBars();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Soal berhasil dihapus'),
                    duration: Duration(milliseconds: 1500),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.success,
                  ),
                );
                _loadQuestions();
              }
            },
            child: Text(
              'Hapus',
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.tema,
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _loadQuestions,
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
                  // kartu info tema
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                                widget.kategori.toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_questions.length} Soal Tersedia',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.tema,
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daftar Soal',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Tambah Soal',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () => _showQuestionFormDialog(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (_questions.isEmpty)
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
                              'Belum ada soal untuk tema ini.',
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
                      children: List.generate(_questions.length, (index) {
                        final q = _questions[index];
                        return _buildQuestionCard(q, index + 1);
                      }),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildQuestionCard(QuizSQLModel question, int number) {
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
          // header kartu soal
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Soal $number',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () =>
                      _showQuestionFormDialog(questionToEdit: question),
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
                  onTap: () => _confirmDeleteQuestion(question),
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
                Text(
                  question.soal,
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (question.gambar != null &&
                    question.gambar!.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 130,
                      width: double.infinity,
                      child: AppImageView(
                        imagePath: question.gambar!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                // pratinjau pilihan jawaban
                Text(
                  'Pilihan Jawaban:',
                  style: AppTypography.labelBold(fontSize: 11),
                ),
                const SizedBox(height: 4),
                ...List.generate(question.daftarJawaban.length, (optIdx) {
                  final isCorrect = optIdx == question.jawabanBenar;
                  final labels = ['A', 'B', 'C', 'D', 'E'];
                  final label = optIdx < labels.length
                      ? labels[optIdx]
                      : '$optIdx';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Icon(
                          isCorrect
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked,
                          size: 14,
                          color: isCorrect
                              ? AppColors.success
                              : AppColors.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '$label. ${question.daftarJawaban[optIdx]}',
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

                if (question.penjelasan != null &&
                    question.penjelasan!.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Text(
                      'Pembahasan: ${question.penjelasan!}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
