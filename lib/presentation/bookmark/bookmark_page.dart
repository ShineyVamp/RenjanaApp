import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/navigation.dart';
import '../../core/widgets/app_bar_halaman.dart';
import '../../core/widgets/app_image.dart';
import '../../data/models/bookmark_model.dart';
import '../../data/repositories/bookmark_repository.dart';
import '../detail/detail_budaya_page.dart';
import '../detail/detail_sejarah_page.dart';
import '../wilayah/detail_provinsi_page.dart';
import '../wilayah/detail_pulau_page.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  final BookmarkRepository _bookmarkRepository = BookmarkRepository();
  List<BookmarkItemModel> _bookmarks = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedTab = 'SEMUA'; // SEMUA | SEJARAH | BUDAYA | WILAYAH

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    setState(() => _isLoading = true);
    try {
      final list = await _bookmarkRepository.getAllBookmarks();
      if (!mounted) return;
      setState(() {
        _bookmarks = list;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<BookmarkItemModel> get _filteredBookmarks {
    return _bookmarks.where((item) {
      // Pulau dan provinsi disatukan di bawah satu chip Wilayah.
      final matchesTab =
          _selectedTab == 'SEMUA' ||
          (_selectedTab == 'WILAYAH'
              ? item.isWilayah
              : item.itemType.toUpperCase() == _selectedTab);
      final matchesQuery =
          _searchQuery.isEmpty ||
          item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.subtitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesTab && matchesQuery;
    }).toList();
  }

  Future<void> _removeBookmark(BookmarkItemModel item) async {
    final messenger = ScaffoldMessenger.of(context);
    await _bookmarkRepository.removeBookmark(item.kodeTag);
    if (!mounted) return;
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text('"${item.title}" berhasil dihapus dari bookmark'),
        backgroundColor: AppColors.success,
        duration: const Duration(milliseconds: 1000),
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.horizontal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
    _loadBookmarks();
  }

  void _openDetail(BookmarkItemModel item) async {
    ScaffoldMessenger.of(context).clearSnackBars();
    if (item.itemType == 'sejarah' && item.sejarah != null) {
      await context.push(DetailSejarahPage(sejarah: item.sejarah!));
    } else if (item.itemType == 'budaya' && item.budaya != null) {
      await context.push(DetailBudayaPage(budaya: item.budaya!));
    } else if (item.itemType == 'pulau' && item.pulau != null) {
      await context.push(DetailPulauPage(pulau: item.pulau!));
    } else if (item.itemType == 'provinsi' && item.wilayah != null) {
      await context.push(DetailProvinsiPage(provinsi: item.wilayah!));
    }
    _loadBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredBookmarks;
    final totalSejarah = _bookmarks
        .where((b) => b.itemType == 'sejarah')
        .length;
    final totalBudaya = _bookmarks.where((b) => b.itemType == 'budaya').length;
    final totalWilayah = _bookmarks.where((b) => b.isWilayah).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarHalaman(
        judul: 'Koleksi Tersimpan',
        onKembali: () {
          ScaffoldMessenger.of(context).clearSnackBars();
          context.pop();
        },
        aksi: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _loadBookmarks,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : Column(
                  children: [
                    // header pencarian & filter
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.borderLight,
                            width: 0.8,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          // kotak pencarian
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Cari konten tersimpan...',
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                              filled: true,
                              fillColor: AppColors.surface,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.borderLight,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.borderLight,
                                ),
                              ),
                            ),
                            onChanged: (val) =>
                                setState(() => _searchQuery = val),
                          ),
                          const SizedBox(height: 12),

                          // chip filter kategori
                          Row(
                            children: [
                              _buildTabChip(
                                'SEMUA',
                                'Semua (${_bookmarks.length})',
                              ),
                              const SizedBox(width: 8),
                              _buildTabChip(
                                'SEJARAH',
                                'Sejarah ($totalSejarah)',
                              ),
                              const SizedBox(width: 8),
                              _buildTabChip('BUDAYA', 'Budaya ($totalBudaya)'),
                              const SizedBox(width: 8),
                              _buildTabChip(
                                'WILAYAH',
                                'Wilayah ($totalWilayah)',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // daftar item tersimpan
                    Expanded(
                      child: filtered.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              color: AppColors.primary,
                              onRefresh: _loadBookmarks,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(20),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final item = filtered[index];
                                  return _buildBookmarkCard(item);
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

  Widget _buildTabChip(String tabKey, String label) {
    final isSelected = _selectedTab == tabKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = tabKey),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderLight,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookmarkCard(BookmarkItemModel item) {
    final isSejarah = item.itemType == 'sejarah';

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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _openDetail(item),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header kartu
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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
                        color: isSejarah
                            ? AppColors.primary
                            : AppColors.accentBudaya,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.itemType.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => _removeBookmark(item),
                      borderRadius: BorderRadius.circular(6),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.bookmark_remove_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // isi kartu
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: AppImageView(
                          imagePath: item.imagePath,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.description,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'Baca Selengkapnya',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 13,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark_border_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Tidak Ada Hasil'
                  : 'Belum Ada Konten Tersimpan',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Tidak ditemukan konten tersimpan yang cocok dengan "$_searchQuery".'
                  : 'Jelajahi kisah sejarah dan ragam mahakarya budaya Indonesia lalu simpan artikel favorit Anda di sini.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(
                Icons.explore_outlined,
                color: Colors.white,
                size: 18,
              ),
              label: Text(
                'Mulai Menjelajah',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
