import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dekorasi.dart';
import '../../core/constants/app_typography.dart';
import '../../core/extensions/navigation.dart';
import '../../core/widgets/app_bar_halaman.dart';
import '../../core/widgets/app_image.dart';
import '../../core/constants/budaya_kategori.dart';
import '../../data/models/budaya_model.dart';
import '../../data/repositories/budaya_repository.dart';
import '../detail/detail_budaya_page.dart';

// Daftar koleksi budaya pada satu kategori.
class KoleksiKategoriPage extends StatefulWidget {
  final BudayaKategori kategori;

  const KoleksiKategoriPage({super.key, required this.kategori});

  @override
  State<KoleksiKategoriPage> createState() => _KoleksiKategoriPageState();
}

class _KoleksiKategoriPageState extends State<KoleksiKategoriPage> {
  final BudayaRepository _budayaRepository = BudayaRepository();

  List<BudayaModel> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final list = await _budayaRepository.getBudayaByJenis(widget.kategori.kode);
    if (!mounted) return;
    setState(() {
      _items = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarHalaman(judul: widget.kategori.nama),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : _items.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _loadItems,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    itemCount: _items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) =>
                        _buildItemCard(_items[index]),
                  ),
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
            Icons.inventory_2_outlined,
            size: 48,
            color: AppColors.surfaceMuted,
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada koleksi ${widget.kategori.nama}',
            textAlign: TextAlign.center,
            style: AppTypography.labelBold(fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            'Koleksi untuk kategori ini akan tampil di sini setelah ditambahkan.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium(),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(BudayaModel item) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push(DetailBudayaPage(budaya: item)),
      child: Container(
        decoration: AppDekorasi.panel(),
        // tinggi kartu ikut isi teks, gambar dikunci lewat AspectRatio
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
                  mainAxisAlignment: MainAxisAlignment.center,
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
                        if (item.isDestinasi) ...[
                          const SizedBox(width: 6),
                          Container(
                            color: AppColors.accentBudaya,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            child: Text(
                              'DESTINASI',
                              style: AppTypography.tag(),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.judul,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headingSmall().copyWith(
                        fontSize: 19,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.tagline.isNotEmpty ? item.tagline : item.deskripsi,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall(),
                    ),
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
