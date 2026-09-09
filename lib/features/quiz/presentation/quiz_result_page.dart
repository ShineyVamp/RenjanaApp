import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dekorasi.dart';
import '../../../core/extensions/navigation.dart';
import '../../../core/widgets/app_image.dart';
import 'package:renjana/features/capaian/presentation/riwayat_kuis_page.dart';
import 'package:renjana/features/quiz/data/models/hasil_kuis_model.dart';
import 'quiz_play_page.dart';

class QuizResultPage extends StatefulWidget {
  final String title;
  final String category;
  final List<PlayQuestionItem> playItems;
  final int correctCount;
  final int incorrectCount;
  final int elapsedSeconds;

  // Kosong bila kuisnya campuran sekategori, sehingga tidak punya rekor tema.
  final String tema;

  // Rekor tema ini sebelum percobaan barusan disimpan; null bila belum ada.
  final HasilKuis? rekorSebelumnya;

  const QuizResultPage({
    super.key,
    required this.title,
    required this.category,
    required this.playItems,
    required this.correctCount,
    required this.incorrectCount,
    required this.elapsedSeconds,
    this.tema = '',
    this.rekorSebelumnya,
  });

  @override
  State<QuizResultPage> createState() => _QuizResultPageState();
}

class _QuizResultPageState extends State<QuizResultPage> {
  int _selectedFilter = 0; // 0 = Semua, 1 = Benar, 2 = Salah

  // Mengulang kuis dengan soal yang sama.
  // Baris rekor hanya muncul pada kuis satu tema; kuis acak sekategori tidak
  // punya rekor karena isi soalnya berganti-ganti.
  Widget _buildBarisRekor() {
    if (widget.tema.trim().isEmpty) return const SizedBox.shrink();

    final lama = widget.rekorSebelumnya;
    final pecah =
        lama == null ||
        widget.correctCount > lama.benar ||
        (widget.correctCount == lama.benar &&
            widget.elapsedSeconds < lama.detik);

    final warna = pecah ? AppColors.gold : AppColors.border;
    final judul = lama == null
        ? 'Rekor pertama tema ini'
        : (pecah ? 'Rekor baru' : 'Rekor tema ini');
    final keterangan = lama == null
        ? 'Capaian ini menjadi patokan untuk percobaan berikutnya.'
        : 'Sebelumnya ${lama.benar}/${lama.jumlahSoal} benar '
              'dalam ${lama.waktuTerbaca}.';

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: GestureDetector(
        onTap: () => context.push(const RiwayatKuisPage()),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
          decoration: AppDekorasi.panelCapaian(warna, menonjol: pecah),
          child: Row(
            children: [
              Icon(
                pecah
                    ? Icons.emoji_events_rounded
                    : Icons.emoji_events_outlined,
                size: 20,
                color: pecah ? AppColors.gold : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      judul,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                        color: pecah ? AppColors.gold : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      keterangan,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _restartQuiz() {
    context.pushReplacement(
      QuizPlayPage(
        title: widget.title,
        category: widget.category,
        questions: widget.playItems.map((item) => item.original).toList(),
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  List<PlayQuestionItem> get _filteredItems {
    if (_selectedFilter == 1) {
      return widget.playItems.where((item) => item.isCorrect).toList();
    }
    if (_selectedFilter == 2) {
      return widget.playItems.where((item) => !item.isCorrect).toList();
    }
    return widget.playItems;
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.playItems.length;
    final scorePercent = total > 0 ? (widget.correctCount / total) * 100 : 0;

    String feedbackTitle = 'Luar Biasa!';
    String feedbackDesc =
        'Pengetahuan Anda tentang sejarah & budaya sangat mengagumkan!';
    Color feedbackColor = AppColors.success;
    IconData feedbackIcon = Icons.military_tech_rounded;

    if (scorePercent == 100) {
      feedbackTitle = 'Sempurna!';
      feedbackDesc =
          'Semua jawaban Anda benar! Anda adalah penjelajah nusantara sejati.';
      feedbackColor = AppColors.gold;
      feedbackIcon = Icons.workspace_premium_rounded;
    } else if (scorePercent >= 70) {
      feedbackTitle = 'Hebat Sekali!';
      feedbackDesc =
          'Hasil kuis Anda sangat memuaskan, terus tingkatkan pengetahuan!';
      feedbackColor = AppColors.success;
      feedbackIcon = Icons.thumb_up_alt_rounded;
    } else if (scorePercent >= 50) {
      feedbackTitle = 'Cukup Bagus!';
      feedbackDesc =
          'Anda sudah memiliki dasar yang baik. Pelajari lagi materi untuk hasil maksimal.';
      feedbackColor = AppColors.warning;
      feedbackIcon = Icons.lightbulb_outline_rounded;
    } else {
      feedbackTitle = 'Jangan Menyerah!';
      feedbackDesc =
          'Jadikan ini kesempatan untuk mempelajari kembali kekayaan sejarah dan budaya.';
      feedbackColor = AppColors.error;
      feedbackIcon = Icons.refresh_rounded;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Hasil Kuis',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.primary),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        shape: const Border(
          bottom: BorderSide(color: AppColors.primary, width: 0.8),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // badge kategori & tema
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.title.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // kartu skor & feedback
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: feedbackColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          feedbackIcon,
                          color: feedbackColor,
                          size: 38,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        feedbackTitle,
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        feedbackDesc,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: AppColors.borderLight),
                      const SizedBox(height: 16),

                      // ringkasan benar/salah
                      Row(
                        children: [
                          _buildStatItem(
                            label: 'Skor',
                            value: '${scorePercent.toInt()}%',
                            color: feedbackColor,
                          ),
                          _buildStatItem(
                            label: 'Benar',
                            value: '${widget.correctCount}',
                            color: AppColors.success,
                          ),
                          _buildStatItem(
                            label: 'Salah',
                            value: '${widget.incorrectCount}',
                            color: AppColors.error,
                          ),
                          _buildStatItem(
                            label: 'Waktu',
                            value: _formatDuration(widget.elapsedSeconds),
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // section rekor tema
                _buildBarisRekor(),
                const SizedBox(height: 20),

                // tombol ulangi & selesai
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        label: Text(
                          'Ulangi Kuis',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        onPressed: _restartQuiz,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(
                          Icons.home_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: Text(
                          'Menu Kuis',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // section review jawaban
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pembahasan Soal',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    // chip filter semua/benar/salah
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          _buildFilterTab(0, 'Semua'),
                          _buildFilterTab(1, 'Benar'),
                          _buildFilterTab(2, 'Salah'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // daftar review
                ...List.generate(_filteredItems.length, (index) {
                  final item = _filteredItems[index];
                  final originalIndex = widget.playItems.indexOf(item);
                  final quiz = item.original;
                  final isCorrect = item.isCorrect;
                  final userAnswer = item.selectedIndex != null
                      ? item.shuffledOptions[item.selectedIndex!]
                      : '-';
                  final correctAnswer =
                      item.shuffledOptions[item.correctShuffledIndex];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCorrect
                            ? AppColors.success.withValues(alpha: 0.4)
                            : AppColors.error.withValues(alpha: 0.4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ExpansionTile(
                      shape: const Border(),
                      initiallyExpanded: !isCorrect,
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isCorrect
                              ? AppColors.success.withValues(alpha: 0.15)
                              : AppColors.error.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCorrect ? Icons.check_rounded : Icons.close_rounded,
                          color: isCorrect
                              ? AppColors.success
                              : AppColors.error,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        'Soal ${originalIndex + 1}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isCorrect
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                      subtitle: Text(
                        quiz.soal,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [
                        const Divider(color: AppColors.borderLight),
                        const SizedBox(height: 8),

                        // gambar soal, opsional
                        if (quiz.gambar != null &&
                            quiz.gambar!.trim().isNotEmpty) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              height: 140,
                              width: double.infinity,
                              child: AppImageView(
                                imagePath: quiz.gambar!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // jawaban user dan kunci
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jawaban Anda: ',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                userAnswer,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isCorrect
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (!isCorrect) ...[
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kunci Jawaban: ',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  correctAnswer,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 10),

                        // kotak penjelasan
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Penjelasan / Pembahasan:',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                (quiz.penjelasan != null &&
                                        quiz.penjelasan!.trim().isNotEmpty)
                                    ? quiz.penjelasan!
                                    : 'Jawaban yang tepat adalah $correctAnswer.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  height: 1.4,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(int index, String title) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
