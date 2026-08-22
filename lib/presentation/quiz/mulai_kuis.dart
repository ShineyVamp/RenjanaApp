import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/extensions/navigation.dart';
import '../../core/widgets/pembersih_dialog.dart';
import '../../data/models/quiz_model.dart';
import '../../data/models/tema_kuis_model.dart';
import '../../data/repositories/quiz_repository.dart';
import 'quiz_play_page.dart';

// Dua cara memulai kuis, dipakai halaman Kuis maupun halaman kategori.

// Memulai kuis satu tema utuh, urutan soalnya diacak.
void mulaiKuisTema(BuildContext context, TemaKuis tema) {
  if (tema.soal.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Belum ada soal untuk tema ini.'),
        backgroundColor: AppColors.primaryDark,
      ),
    );
    return;
  }

  final acak = List<QuizSQLModel>.from(tema.soal)..shuffle();
  context.push(
    QuizPlayPage(title: tema.tema, category: tema.kategori, questions: acak),
  );
}

// Membuka pilihan jumlah soal, lalu memulai kuis acak dari seluruh
// kategori.
Future<void> tampilkanSheetKuisKategori(
  BuildContext context,
  String namaKategori, {
  QuizRepository? repository,
}) async {
  final quizRepository = repository ?? QuizRepository();
  final tersedia = await quizRepository.getQuizCountByKategori(namaKategori);
  if (!context.mounted) return;

  int jumlahDipilih = tersedia > 0 ? (tersedia < 10 ? tersedia : 10) : 10;
  final pengendaliManual = TextEditingController(text: '$jumlahDipilih');
  bool manual = false;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (modalCtx) {
      return PembersihDialog(
        onTutup: () => buangController([pengendaliManual]),
        child: StatefulBuilder(
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
                            namaKategori.toUpperCase(),
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
                    'Soal akan dipilih secara acak (random) dari berbagai tema dalam kategori $namaKategori.',
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
                          'Total bank soal tersedia: $tersedia soal',
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
                    children: [10, 20, 50].map((jumlah) {
                      final terpilih = !manual && jumlahDipilih == jumlah;
                      return ChoiceChip(
                        label: Text('$jumlah Soal'),
                        selected: terpilih,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          color: terpilih
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                        side: BorderSide(
                          color: terpilih
                              ? AppColors.primary
                              : AppColors.borderLight,
                        ),
                        onSelected: (dipilih) {
                          if (!dipilih) return;
                          setModalState(() {
                            manual = false;
                            jumlahDipilih = jumlah;
                            pengendaliManual.text = '$jumlah';
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // input jumlah soal manual
                  TextField(
                    controller: pengendaliManual,
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
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    onChanged: (nilai) {
                      final angka = int.tryParse(nilai.trim());
                      if (angka == null || angka <= 0) return;
                      setModalState(() {
                        manual = true;
                        jumlahDipilih = angka;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

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
                        final diketik =
                            int.tryParse(pengendaliManual.text.trim()) ??
                            jumlahDipilih;
                        final target = diketik > 0 ? diketik : 10;

                        Navigator.pop(modalCtx);

                        final soal = await quizRepository
                            .getRandomQuizzesByCategory(namaKategori, target);
                        if (!context.mounted) return;

                        if (soal.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Belum ada soal untuk kategori $namaKategori.',
                              ),
                              backgroundColor: AppColors.primaryDark,
                            ),
                          );
                          return;
                        }

                        context.push(
                          QuizPlayPage(
                            title: 'Kuis $namaKategori',
                            category: namaKategori,
                            questions: soal,
                          ),
                        );
                      },
                      child: Text(
                        'Mulai Kuis ($jumlahDipilih Soal)',
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
        ),
      );
    },
  );
}
