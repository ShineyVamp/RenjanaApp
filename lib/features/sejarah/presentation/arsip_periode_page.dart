import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dekorasi.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/katalog_kategori.dart';
import '../../../core/extensions/navigation.dart';
import '../../../core/widgets/app_bar_halaman.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/kotak_pencarian.dart';
import 'package:renjana/features/sejarah/data/models/sejarah_model.dart';
import 'package:renjana/features/sejarah/data/repositories/sejarah_repository.dart';
import 'detail_sejarah_page.dart';

// Halaman penelusuran arsip sejarah berdasarkan era/periode zaman.
class ArsipPeriodePage extends StatefulWidget {
  final KategoriItem periode;

  const ArsipPeriodePage({super.key, required this.periode});

  @override
  State<ArsipPeriodePage> createState() => _ArsipPeriodePageState();
}

class _ArsipPeriodePageState extends State<ArsipPeriodePage> {
  final SejarahRepository _sejarahRepository = SejarahRepository();
  final TextEditingController _searchController = TextEditingController();

  List<SejarahModel> _semuaItems = [];
  bool _isLoading = true;
  String _selectedJenisPeristiwa = '';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final list = await _sejarahRepository.getSejarahByPeriode(
      widget.periode.kode,
    );
    if (!mounted) return;
    setState(() {
      _semuaItems = list;
      _isLoading = false;
    });
  }

  List<SejarahModel> get _filteredItems {
    var list = _semuaItems;

    if (_selectedJenisPeristiwa.isNotEmpty) {
      list = list
          .where(
            (item) =>
                (item.jenisPeristiwa?.trim().toUpperCase() ?? '') ==
                _selectedJenisPeristiwa.toUpperCase(),
          )
          .toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((item) {
        final content =
            '${item.judul} ${item.subtitle} ${item.ringkasan} ${item.provinsi ?? ''} ${item.kodeTag}'
                .toLowerCase();
        return content.contains(q);
      }).toList();
    }

    return list;
  }

  Set<String> get _tersediaJenisPeristiwa {
    return _semuaItems
        .map((e) => e.jenisPeristiwa?.trim().toUpperCase() ?? '')
        .where((e) => e.isNotEmpty)
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarHalaman(judul: widget.periode.nama),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              // Header deskripsi era dan pencarian
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Garis Waktu Nusantara',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.periode.nama,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    KotakPencarian(
                      controller: _searchController,
                      petunjuk: 'Cari dalam era ${widget.periode.nama}...',
                      onChanged: (val) => setState(() => _searchQuery = val),
                      onBersihkan: () => setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      }),
                    ),
                  ],
                ),
              ),

              // Filter chips untuk jenis peristiwa
              if (_tersediaJenisPeristiwa.length > 1)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: const Text('Semua'),
                          selected: _selectedJenisPeristiwa.isEmpty,
                          selectedColor: AppColors.primary,
                          labelStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _selectedJenisPeristiwa.isEmpty
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedJenisPeristiwa = '');
                            }
                          },
                        ),
                      ),
                      ..._tersediaJenisPeristiwa.map((kode) {
                        final isSelected =
                            _selectedJenisPeristiwa.toUpperCase() == kode;
                        final label = namaPeristiwa(kode);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            labelStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                            onSelected: (selected) {
                              setState(() {
                                _selectedJenisPeristiwa = selected ? kode : '';
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // Daftar konten
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : filtered.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: _loadData,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) =>
                              _buildHistoryCard(filtered[index]),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.auto_stories_outlined,
            size: 48,
            color: AppColors.surfaceMuted,
          ),
          const SizedBox(height: 12),
          Text(
            _searchQuery.isNotEmpty || _selectedJenisPeristiwa.isNotEmpty
                ? 'Tidak ada arsip yang cocok'
                : 'Belum ada arsip pada era ${widget.periode.nama}',
            textAlign: TextAlign.center,
            style: AppTypography.labelBold(fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            _searchQuery.isNotEmpty || _selectedJenisPeristiwa.isNotEmpty
                ? 'Coba gunakan kata kunci lain atau bersihkan filter.'
                : 'Arsip sejarah untuk era ini akan tampil setelah ditambahkan.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium(),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(SejarahModel item) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        await context.push(DetailSejarahPage(sejarah: item));
        await _loadData();
      },
      child: Container(
        decoration: AppDekorasi.panel(),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              child: AspectRatio(
                aspectRatio: 1,
                child: AppImageView(
                  imagePath: item.gambarUtama,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          color: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          child: Text(item.kodeTag, style: AppTypography.tag()),
                        ),
                        if (item.jenisPeristiwa != null &&
                            item.jenisPeristiwa!.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.border),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            child: Text(
                              item.namaPeristiwaLabel,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.judul,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (item.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                    if (item.provinsi != null && item.provinsi!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              item.provinsi!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
