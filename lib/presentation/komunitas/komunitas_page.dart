import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dekorasi.dart';
import '../../core/extensions/navigation.dart';
import '../../core/widgets/header_halaman.dart';
import '../../data/models/komunitas_model.dart';
import '../../data/repositories/komunitas_repository.dart';
import 'detail_diskusi_page.dart';
import 'form_diskusi_page.dart';

class KomunitasPage extends StatefulWidget {
  const KomunitasPage({super.key});

  @override
  State<KomunitasPage> createState() => _KomunitasPageState();
}

class _KomunitasPageState extends State<KomunitasPage> {
  final KomunitasRepository _repository = KomunitasRepository();
  final TextEditingController _searchController = TextEditingController();

  List<DiskusiModel> _daftarDiskusi = [];
  bool _isLoading = true;
  String _kategoriTerpilih = 'Semua';

  static const List<String> _kategoriList = [
    'Semua',
    'Budaya',
    'Sejarah',
    'Kedaerahan',
    'Umum',
  ];

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _muatData({bool showLoader = true}) async {
    if (showLoader) setState(() => _isLoading = true);
    final hasil = await _repository.getDaftarDiskusi(
      kategori: _kategoriTerpilih == 'Semua' ? null : _kategoriTerpilih,
      kataKunci: _searchController.text.trim(),
    );
    if (!mounted) return;
    setState(() {
      _daftarDiskusi = hasil;
      _isLoading = false;
    });
  }

  String _formatWaktu(DateTime waktu) {
    final selisih = DateTime.now().difference(waktu);
    if (selisih.inDays > 30) {
      return '${waktu.day}/${waktu.month}/${waktu.year}';
    } else if (selisih.inDays > 0) {
      return '${selisih.inDays}h lalu';
    } else if (selisih.inHours > 0) {
      return '${selisih.inHours}j lalu';
    } else if (selisih.inMinutes > 0) {
      return '${selisih.inMinutes}m lalu';
    } else {
      return 'Baru saja';
    }
  }

  Future<void> _bukaFormDiskusi() async {
    final dibuat = await context.push(const FormDiskusiPage());
    if (dibuat == true && mounted) {
      await _muatData(showLoader: false);
    }
  }

  Future<void> _bukaDetail(DiskusiModel diskusi) async {
    await context.push(DetailDiskusiPage(diskusiId: diskusi.id!));
    if (!mounted) return;
    await _muatData(showLoader: false);
  }

  Future<void> _toggleSuara(DiskusiModel diskusi) async {
    if (diskusi.id == null) return;
    await _repository.toggleSuara('diskusi', diskusi.id!);
    await _muatData(showLoader: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _bukaFormDiskusi,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
        label: Text(
          'Tanya Komunitas',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderHalaman(judul: 'Komunitas', garisBawah: false),

            // Search Bar & Filter Chips
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => _muatData(showLoader: false),
                  decoration: InputDecoration(
                    hintText: 'Cari topik diskusi atau pertanyaan...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _muatData(showLoader: false);
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),

            // Kategori Choice Chips
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _kategoriList.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final kat = _kategoriList[index];
                  final isSelected = _kategoriTerpilih == kat;
                  return ChoiceChip(
                    label: Text(kat),
                    selected: isSelected,
                    onSelected: (val) {
                      if (!val) return;
                      setState(() => _kategoriTerpilih = kat);
                      _muatData(showLoader: false);
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    labelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // Discussion List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () => _muatData(showLoader: false),
                      child: _daftarDiskusi.isEmpty
                          ? ListView(
                              children: [
                                const SizedBox(height: 80),
                                Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.forum_outlined,
                                        size: 64,
                                        color: AppColors.surfaceMuted,
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        'Belum Ada Diskusi',
                                        style: GoogleFonts.dmSerifDisplay(
                                          fontSize: 20,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Jadilah yang pertama memulai percakapan!',
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
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                              itemCount: _daftarDiskusi.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = _daftarDiskusi[index];
                                return _KartuDiskusi(
                                  item: item,
                                  waktuTeks: _formatWaktu(item.dibuatPada),
                                  onTap: () => _bukaDetail(item),
                                  onVote: () => _toggleSuara(item),
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

class _KartuDiskusi extends StatelessWidget {
  final DiskusiModel item;
  final String waktuTeks;
  final VoidCallback onTap;
  final VoidCallback onVote;

  const _KartuDiskusi({
    required this.item,
    required this.waktuTeks,
    required this.onTap,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    final adaRef = item.refArsip != null && item.refArsip!.trim().isNotEmpty;
    final isVoted = item.suaraSaya > 0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppDekorasi.panel(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Penulis, Waktu & Kategori
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primaryDark.withAlpha(30),
                  child: Text(
                    item.penulis.isNotEmpty ? item.penulis[0].toUpperCase() : 'P',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.penulis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        waktuTeks,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withAlpha(50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.kategori,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Judul
            Text(
              item.judul,
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),

            // Cuplikan Isi
            Text(
              item.isi,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            // Tautan Arsip bila ada
            if (adaRef) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderPrimary),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.link_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tautan Arsip: ${item.refArsip}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Baris Aksi (Suara & Komentar)
            Row(
              children: [
                GestureDetector(
                  onTap: onVote,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isVoted
                          ? AppColors.primary.withAlpha(25)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isVoted ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isVoted
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_upward_outlined,
                          size: 14,
                          color: isVoted ? AppColors.primary : AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.jumlahSuara}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: isVoted ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 15,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${item.jumlahJawaban} Jawaban',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
