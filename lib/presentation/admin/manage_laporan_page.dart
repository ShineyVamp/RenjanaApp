import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dekorasi.dart';
import '../../core/widgets/app_bar_halaman.dart';
import '../../data/models/laporan_model.dart';
import '../../data/repositories/komunitas_repository.dart';
import '../../data/repositories/laporan_repository.dart';

class AdminManageLaporanPage extends StatefulWidget {
  const AdminManageLaporanPage({super.key});

  @override
  State<AdminManageLaporanPage> createState() => _AdminManageLaporanPageState();
}

class _AdminManageLaporanPageState extends State<AdminManageLaporanPage> {
  final LaporanRepository _repository = LaporanRepository();
  final KomunitasRepository _komunitasRepository = KomunitasRepository();

  List<LaporanModel> _daftarLaporan = [];
  bool _isLoading = true;
  String _filterStatus = 'semua';

  static const List<String> _statusOptions = [
    'semua',
    'menunggu',
    'disetujui',
    'ditolak',
  ];

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    setState(() => _isLoading = true);
    final hasil = await _repository.getSemuaLaporan(
      status: _filterStatus == 'semua' ? null : _filterStatus,
    );
    if (!mounted) return;
    setState(() {
      _daftarLaporan = hasil;
      _isLoading = false;
    });
  }

  Future<void> _prosesLaporan(LaporanModel laporan, String statusBaru) async {
    if (laporan.id == null) return;

    if (statusBaru == 'disetujui') {
      final konfirmasi = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Setujui & Hapus Konten?',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            'Laporan akan disetujui. Bila target adalah diskusi atau jawaban, konten tersebut dapat dihapus langsung dari database.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(
                'Setujui & Tindak Lanjut',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );

      if (konfirmasi != true) return;

      // Hapus konten bila target diskusi
      if (laporan.targetTipe == 'diskusi') {
        final id = int.tryParse(laporan.targetId);
        if (id != null) {
          await _komunitasRepository.hapusDiskusi(id);
        }
      }
    }

    await _repository.perbaruiStatus(laporan.id!, statusBaru);
    await _muatData();
  }

  Color _warnaStatus(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
        return AppColors.error;
      case 'ditolak':
        return AppColors.success;
      case 'menunggu':
      default:
        return AppColors.accentBudaya;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppBarHalaman(judul: 'Moderasi Laporan'),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Filter status
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
              child: SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _statusOptions.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final st = _statusOptions[index];
                    final isSelected = _filterStatus == st;
                    return ChoiceChip(
                      label: Text(st.toUpperCase()),
                      selected: isSelected,
                      onSelected: (val) {
                        if (!val) return;
                        setState(() => _filterStatus = st);
                        _muatData();
                      },
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      labelStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      showCheckmark: false,
                    );
                  },
                ),
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _muatData,
                      child: _daftarLaporan.isEmpty
                          ? ListView(
                              children: [
                                const SizedBox(height: 80),
                                Center(
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.check_circle_outline_rounded,
                                        size: 64,
                                        color: AppColors.success,
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        'Semua Bersih',
                                        style: GoogleFonts.dmSerifDisplay(
                                          fontSize: 20,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Tidak ada laporan pada kategori ini.',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                6,
                                20,
                                40,
                              ),
                              itemCount: _daftarLaporan.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = _daftarLaporan[index];
                                final warnaSt = _warnaStatus(item.status);
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: AppDekorasi.panel(),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets
                                                .symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryDark
                                                  .withAlpha(25),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              item.targetTipe.toUpperCase(),
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primaryDark,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Target: ${item.targetId}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets
                                                .symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: warnaSt.withAlpha(25),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border:
                                                  Border.all(color: warnaSt),
                                            ),
                                            child: Text(
                                              item.status.toUpperCase(),
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: warnaSt,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),

                                      Text(
                                        item.alasan,
                                        style: GoogleFonts.dmSerifDisplay(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),

                                      if (item.kontenTeks != null &&
                                          item.kontenTeks!.isNotEmpty) ...[
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: AppColors.surface,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: AppColors.border,
                                            ),
                                          ),
                                          child: Text(
                                            item.kontenTeks!,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                      ],

                                      Text(
                                        'Dilaporkan oleh: ${item.pelapor}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      if (item.status == 'menunggu') ...[
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                style: OutlinedButton
                                                    .styleFrom(
                                                  side: const BorderSide(
                                                    color: AppColors.success,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                                ),
                                                onPressed: () =>
                                                    _prosesLaporan(
                                                  item,
                                                  'ditolak',
                                                ),
                                                child: Text(
                                                  'Tolak (Aman)',
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color: AppColors.success,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: ElevatedButton(
                                                style: ElevatedButton
                                                    .styleFrom(
                                                  backgroundColor:
                                                      AppColors.error,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                                ),
                                                onPressed: () =>
                                                    _prosesLaporan(
                                                  item,
                                                  'disetujui',
                                                ),
                                                child: Text(
                                                  'Setujui (Tindak)',
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
