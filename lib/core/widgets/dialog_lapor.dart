import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../../data/models/laporan_model.dart';
import '../../data/repositories/laporan_repository.dart';
import '../../services/preference_handler.dart';

Future<void> tampilkanDialogLapor(
  BuildContext context, {
  required String targetTipe,
  required String targetId,
  String? kontenTeks,
}) async {
  final alasanList = [
    'Informasi Keliru / Menyesatkan',
    'Ujaran Kebencian / SARA',
    'Spam atau Promosi Iklan',
    'Konten Tidak Pantas / Melanggar Norma',
    'Lainnya',
  ];

  String alasanTerpilih = alasanList.first;
  final catatanController = TextEditingController();

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    const Icon(
                      Icons.report_problem_outlined,
                      color: AppColors.error,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Laporkan Konten',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Bantu kami menjaga komunitas Renjana tetap informatif, aman, dan nyaman.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Alasan Pelaporan',
                  style: AppTypography.labelBold(fontSize: 13),
                ),
                const SizedBox(height: 8),

                ...alasanList.map((alasan) {
                  final isSelected = alasanTerpilih == alasan;
                  return GestureDetector(
                    onTap: () => setModalState(() => alasanTerpilih = alasan),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_off_rounded,
                            size: 18,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surfaceMuted,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              alasan,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),

                Text(
                  'Catatan Tambahan (Opsional)',
                  style: AppTypography.labelBold(fontSize: 13),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: catatanController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Jelaskan lebih detail bagian yang bermasalah...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      final pelapor = PreferenceHandler.user?.nama ??
                          PreferenceHandler.userName;
                      final gabunganAlasan = catatanController.text.trim().isEmpty
                          ? alasanTerpilih
                          : '$alasanTerpilih: ${catatanController.text.trim()}';

                      await LaporanRepository().buatLaporan(
                        LaporanModel(
                          targetTipe: targetTipe,
                          targetId: targetId,
                          kontenTeks: kontenTeks,
                          pelapor: pelapor.isNotEmpty ? pelapor : 'Anonim',
                          alasan: gabunganAlasan,
                          dibuatPada: DateTime.now(),
                        ),
                      );

                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Laporan Anda telah dikirim dan akan ditinjau oleh moderator.',
                          ),
                          backgroundColor: AppColors.primaryDark,
                        ),
                      );
                    },
                    child: Text(
                      'Kirim Laporan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
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
