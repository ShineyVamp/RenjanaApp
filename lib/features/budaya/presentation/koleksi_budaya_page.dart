import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/budaya_kategori.dart';
import '../../../core/extensions/navigation.dart';
import '../../../core/widgets/app_bar_halaman.dart';
import '../../../core/widgets/kartu_hasil.dart';
import 'package:renjana/features/budaya/data/models/budaya_model.dart';
import 'package:renjana/features/budaya/data/repositories/budaya_repository.dart';
import 'package:renjana/features/jelajah/data/models/hasil_jelajah_model.dart';
import 'detail_budaya_page.dart';

// daftar koleksi budaya
class KoleksiKategoriPage extends StatefulWidget {
  final BudayaKategori kategori;

  const KoleksiKategoriPage({super.key, required this.kategori});

  @override
  State<KoleksiKategoriPage> createState() => _KoleksiKategoriPageState();
}

class _KoleksiKategoriPageState extends State<KoleksiKategoriPage> {
  final BudayaRepository _budayaRepository = BudayaRepository();

  static final Map<String, List<BudayaModel>> _cacheKategori = {};
  List<BudayaModel> _items = [];
  bool _isLoading = true;

  // section siklus hidup
  @override
  void initState() {
    super.initState();
    final cached = _cacheKategori[widget.kategori.kode];
    if (cached != null && cached.isNotEmpty) {
      _items = cached;
      _isLoading = false;
    }
    _loadItems(showLoader: cached == null || cached.isEmpty);
  }

  // section muat data
  Future<void> _loadItems({bool showLoader = true}) async {
    if (showLoader && !_isLoading) {
      setState(() => _isLoading = true);
    }
    final list = await _budayaRepository.getBudayaByJenis(widget.kategori.kode);
    _cacheKategori[widget.kategori.kode] = list;
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
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return KartuHasil(
                        item: HasilJelajah.dariBudaya(item),
                        onTap: () => context.push(
                          DetailBudayaPage(budaya: item),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }

  // status kosong
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
}
