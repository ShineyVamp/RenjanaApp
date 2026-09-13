import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/katalog_kategori.dart';
import '../../../core/extensions/navigation.dart';
import '../../../core/widgets/app_bar_halaman.dart';
import '../../../core/widgets/kartu_hasil.dart';
import '../../../core/widgets/kotak_pencarian.dart';
import 'package:renjana/features/jelajah/data/models/hasil_jelajah_model.dart';
import 'package:renjana/features/sejarah/data/models/sejarah_model.dart';
import 'package:renjana/features/sejarah/data/repositories/sejarah_repository.dart';
import 'detail_sejarah_page.dart';

// section halaman arsip periode
class ArsipPeriodePage extends StatefulWidget {
  final KategoriItem periode;

  const ArsipPeriodePage({super.key, required this.periode});

  @override
  State<ArsipPeriodePage> createState() => _ArsipPeriodePageState();
}

class _ArsipPeriodePageState extends State<ArsipPeriodePage> {
  final SejarahRepository _sejarahRepository = SejarahRepository();
  final TextEditingController _searchController = TextEditingController();

  static final Map<String, List<SejarahModel>> _cachePeriode = {};
  List<SejarahModel> _semuaItems = [];
  bool _isLoading = true;
  String _selectedJenisPeristiwa = '';
  String _searchQuery = '';

  // section siklus hidup
  @override
  void initState() {
    super.initState();
    final cached = _cachePeriode[widget.periode.kode];
    if (cached != null && cached.isNotEmpty) {
      _semuaItems = cached;
      _isLoading = false;
    }
    _loadData(showLoader: cached == null || cached.isEmpty);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // section muat data
  Future<void> _loadData({bool showLoader = true}) async {
    if (showLoader && !_isLoading) {
      setState(() => _isLoading = true);
    }
    final list = await _sejarahRepository.getSejarahByPeriode(
      widget.periode.kode,
    );
    _cachePeriode[widget.periode.kode] = list;
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
              // section header era dan pencarian
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

              // section filter jenis peristiwa
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

              // section daftar arsip periode
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
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            return KartuHasil(
                              item: HasilJelajah.dariSejarah(item),
                              subTag: (item.jenisPeristiwa != null &&
                                      item.jenisPeristiwa!.isNotEmpty)
                                  ? item.namaPeristiwaLabel
                                  : null,
                              lokasi: item.provinsi,
                              onTap: () async {
                                await context.push(
                                  DetailSejarahPage(sejarah: item),
                                );
                                await _loadData();
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // section status kosong
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
}
