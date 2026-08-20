import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/extensions/navigation.dart';
import '../../core/widgets/app_image.dart';
import '../../data/models/quiz_model.dart';
import 'quiz_result_page.dart';

class PlayQuestionItem {
  final QuizSQLModel original;
  final List<String> shuffledOptions;
  final int correctShuffledIndex;
  int? selectedIndex;
  bool isAnswered = false;

  PlayQuestionItem({
    required this.original,
    required this.shuffledOptions,
    required this.correctShuffledIndex,
  });

  bool get isCorrect =>
      selectedIndex != null && selectedIndex == correctShuffledIndex;
}

class QuizPlayPage extends StatefulWidget {
  final String title;
  final String category;
  final List<QuizSQLModel> questions;

  const QuizPlayPage({
    super.key,
    required this.title,
    required this.category,
    required this.questions,
  });

  @override
  State<QuizPlayPage> createState() => _QuizPlayPageState();
}

class _QuizPlayPageState extends State<QuizPlayPage> {
  late List<PlayQuestionItem> _playItems;
  int _currentIndex = 0;
  Timer? _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _setupQuestions();
    _startTimer();
  }

  void _setupQuestions() {
    _playItems = widget.questions.map((q) {
      final String correctText =
          (q.daftarJawaban.isNotEmpty &&
              q.jawabanBenar < q.daftarJawaban.length)
          ? q.daftarJawaban[q.jawabanBenar]
          : (q.daftarJawaban.isNotEmpty ? q.daftarJawaban.first : '');

      // Shuffle options
      final List<String> options = List<String>.from(q.daftarJawaban)
        ..shuffle();
      final int newCorrectIndex = options.indexOf(correctText);

      return PlayQuestionItem(
        original: q,
        shuffledOptions: options,
        correctShuffledIndex: newCorrectIndex >= 0 ? newCorrectIndex : 0,
      );
    }).toList();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _elapsedSeconds++);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _selectAnswer(int index) {
    final current = _playItems[_currentIndex];
    if (current.isAnswered) return;

    setState(() {
      current.selectedIndex = index;
      current.isAnswered = true;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _playItems.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    _timer?.cancel();
    int correct = 0;
    int incorrect = 0;
    for (final item in _playItems) {
      if (item.isCorrect) {
        correct++;
      } else {
        incorrect++;
      }
    }

    context.pushReplacement(
      QuizResultPage(
        title: widget.title,
        category: widget.category,
        playItems: _playItems,
        correctCount: correct,
        incorrectCount: incorrect,
        elapsedSeconds: _elapsedSeconds,
        onRestart: () {
          context.pushReplacement(
            QuizPlayPage(
              title: widget.title,
              category: widget.category,
              questions: widget.questions,
            ),
          );
        },
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Keluar dari Kuis?',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Progres pengerjaan saat ini tidak akan tersimpan jika Anda keluar.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Lanjutkan Kuis',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Keluar',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (_playItems.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Text(
            'Tidak ada soal yang tersedia.',
            style: GoogleFonts.plusJakartaSans(fontSize: 14),
          ),
        ),
      );
    }

    final currentItem = _playItems[_currentIndex];
    final quiz = currentItem.original;
    final progress = (_currentIndex + 1) / _playItems.length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _onWillPop();
        if (shouldExit && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.primary),
            onPressed: () async {
              final shouldExit = await _onWillPop();
              if (shouldExit && context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            widget.title,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDuration(_elapsedSeconds),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.borderLight,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 4,
            ),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Soal Index & Tema
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'SOAL ${_currentIndex + 1} DARI ${_playItems.length}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        if (quiz.tema.isNotEmpty)
                          Flexible(
                            child: Text(
                              quiz.tema.replaceAll('\n', ' '),
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Pertanyaan Soal
                    Text(
                      quiz.soal,
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Gambar Opsional (Hanya jika ada)
                    if (quiz.gambar != null &&
                        quiz.gambar!.trim().isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: AppImageView(
                            imagePath: quiz.gambar!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],

                    // Pilihan Jawaban (Shuffled)
                    Text(
                      'Pilih Jawaban yang Benar:',
                      style: AppTypography.labelBold(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    ...List.generate(currentItem.shuffledOptions.length, (idx) {
                      final optionText = currentItem.shuffledOptions[idx];
                      final isAnswered = currentItem.isAnswered;
                      final isSelected = currentItem.selectedIndex == idx;
                      final isCorrectChoice =
                          idx == currentItem.correctShuffledIndex;

                      Color cardColor = AppColors.surface;
                      Color borderColor = AppColors.borderLight;
                      Color textColor = AppColors.textPrimary;
                      Widget? trailingIcon;

                      if (isAnswered) {
                        if (isCorrectChoice) {
                          cardColor = AppColors.success.withValues(alpha: 0.12);
                          borderColor = AppColors.success;
                          textColor = AppColors.success;
                          trailingIcon = const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.success,
                            size: 22,
                          );
                        } else if (isSelected) {
                          cardColor = AppColors.error.withValues(alpha: 0.12);
                          borderColor = AppColors.error;
                          textColor = AppColors.error;
                          trailingIcon = const Icon(
                            Icons.cancel_rounded,
                            color: AppColors.error,
                            size: 22,
                          );
                        }
                      }

                      final optionLabels = ['A', 'B', 'C', 'D', 'E'];
                      final label = idx < optionLabels.length
                          ? optionLabels[idx]
                          : '${idx + 1}';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: isAnswered ? null : () => _selectAnswer(idx),
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: borderColor,
                                width:
                                    (isAnswered &&
                                        (isCorrectChoice || isSelected))
                                    ? 2
                                    : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: (isAnswered && isCorrectChoice)
                                        ? AppColors.success
                                        : (isAnswered && isSelected)
                                        ? AppColors.error
                                        : AppColors.primary.withValues(
                                            alpha: 0.1,
                                          ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      label,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            (isAnswered &&
                                                (isCorrectChoice || isSelected))
                                            ? Colors.white
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    optionText,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.5,
                                      fontWeight: isAnswered && isCorrectChoice
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                if (trailingIcon != null) ...[
                                  const SizedBox(width: 8),
                                  trailingIcon,
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    // Kotak Pembahasan / Penjelasan jika sudah dijawab
                    if (currentItem.isAnswered) ...[
                      const SizedBox(height: 16),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: currentItem.isCorrect
                              ? AppColors.success.withValues(alpha: 0.08)
                              : AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: currentItem.isCorrect
                                ? AppColors.success.withValues(alpha: 0.3)
                                : AppColors.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  currentItem.isCorrect
                                      ? Icons.check_circle_outline
                                      : Icons.info_outline,
                                  color: currentItem.isCorrect
                                      ? AppColors.success
                                      : AppColors.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  currentItem.isCorrect
                                      ? 'Jawaban Anda Benar!'
                                      : 'Jawaban Anda Kurang Tepat',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: currentItem.isCorrect
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (!currentItem.isCorrect) ...[
                              Text(
                                'Jawaban yang Benar: ${currentItem.shuffledOptions[currentItem.correctShuffledIndex]}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                            Text(
                              'Penjelasan:',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              (quiz.penjelasan != null &&
                                      quiz.penjelasan!.trim().isNotEmpty)
                                  ? quiz.penjelasan!
                                  : 'Jawaban yang benar adalah "${currentItem.shuffledOptions[currentItem.correctShuffledIndex]}".',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                height: 1.4,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tombol Selanjutnya
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
                          onPressed: _nextQuestion,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentIndex < _playItems.length - 1
                                    ? 'Soal Selanjutnya'
                                    : 'Lihat Hasil Kuis',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentIndex < _playItems.length - 1
                                    ? Icons.arrow_forward_rounded
                                    : Icons.military_tech_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
