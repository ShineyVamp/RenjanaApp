import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dekorasi.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/utils/image_picker_helper.dart';
import '../../../core/widgets/app_bar_halaman.dart';
import '../../../core/widgets/app_image.dart';
import '../../wilayah/data/repositories/wilayah_repository.dart';
import '../../wilayah/data/static/data_wilayah_nusantara.dart';

class AdminManageWilayahPage extends StatefulWidget {
  const AdminManageWilayahPage({super.key});

  @override
  State<AdminManageWilayahPage> createState() => _AdminManageWilayahPageState();
}

class _AdminManageWilayahPageState extends State<AdminManageWilayahPage> {
  final WilayahRepository _repository = WilayahRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Provinsi> _provinsiList = const [];
  String _query = '';
  bool _isLoading = true;

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

  Future<void> _muatData() async {
    final list = await _repository.getAllProvinsi(forceRefresh: true);
    if (!mounted) return;
    setState(() {
      _provinsiList = list;
      _isLoading = false;
    });
  }

  void _beriTahu(String pesan, {bool sukses = true}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(pesan),
        duration: const Duration(milliseconds: 1600),
        behavior: SnackBarBehavior.floating,
        backgroundColor: sukses ? AppColors.success : AppColors.primaryDark,
      ),
    );
  }

  Future<void> _unggahDariGaleri(Provinsi prov) async {
    final path = await pilihGambarDariGaleri(context);
    if (path == null || !mounted) return;

    _beriTahu('Mengunggah gambar ${prov.nama} ke Cloudinary...');
    final url = await CloudinaryService().uploadFilePath(
      path,
      subFolder: 'wilayah',
    );

    if (url != null && url.startsWith('http') && mounted) {
      await _repository.updateGambarProvinsi(prov.nama, url);
      await _muatData();
      _beriTahu('Gambar ${prov.nama} berhasil diperbarui');
    } else if (mounted) {
      _beriTahu('Gagal mengunggah gambar', sukses: false);
    }
  }

  Future<void> _inputUrlManual(Provinsi prov) async {
    final controller = TextEditingController(text: prov.gambar ?? '');
    final formKey = GlobalKey<FormState>();

    final hasil = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Tautkan URL Gambar',
          style: AppTypography.labelBold(fontSize: 16),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Masukkan tautan gambar langsung (misal Cloudinary URL) untuk provinsi ${prov.nama}:',
                style: AppTypography.caption(fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'https://res.cloudinary.com/...',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val != null && val.trim().isNotEmpty && !val.trim().startsWith('http')) {
                    return 'URL harus diawali http:// atau https://';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              if (formKey.currentState?.validate() == true) {
                Navigator.pop(ctx, controller.text.trim());
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (hasil != null && mounted) {
      await _repository.updateGambarProvinsi(prov.nama, hasil);
      await _muatData();
      _beriTahu('Gambar ${prov.nama} berhasil diperbarui');
    }
  }

  Future<void> _hapusGambar(Provinsi prov) async {
    await _repository.updateGambarProvinsi(prov.nama, '');
    if (!mounted) return;
    await _muatData();
    _beriTahu('Gambar ${prov.nama} dikembalikan ke default');
  }

  List<Provinsi> get _filteredList {
    if (_query.isEmpty) return _provinsiList;
    final q = _query.toLowerCase();
    return _provinsiList.where((p) {
      final namaCocok = p.nama.toLowerCase().contains(q);
      final julukanCocok = p.julukan.toLowerCase().contains(q);
      final pulau = pulauDariProvinsi(p.nama);
      final pulauCocok = pulau?.nama.toLowerCase().contains(q) ?? false;
      return namaCocok || julukanCocok || pulauCocok;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final denganGambar = _provinsiList.where((p) => p.gambar != null && p.gambar!.trim().startsWith('http')).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppBarHalaman(judul: 'Gambar Wilayah'),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                  children: [
                    // panel informasi ringkasan
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: AppDekorasi.panel(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STATUS GAMBAR PROVINSI',
                            style: AppTypography.eyebrow(),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$denganGambar dari ${_provinsiList.length} provinsi memiliki foto kustom',
                            style: AppTypography.labelBold(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Provinsi tanpa foto kustom menggunakan container fallback atau gambar pulau. '
                            'Anda dapat mengunggah foto baru lewat galeri atau memasukkan URL Cloudinary secara langsung.',
                            style: AppTypography.caption(
                              fontSize: 11,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // kotak pencarian
                    TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _query = val.trim()),
                      decoration: InputDecoration(
                        hintText: 'Cari provinsi, julukan, atau pulau...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _query = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // daftar baris provinsi
                    ..._filteredList.map(_buildBarisProvinsi),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBarisProvinsi(Provinsi prov) {
    final pulau = pulauDariProvinsi(prov.nama);
    final adaGambar = prov.gambar != null && prov.gambar!.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: AppDekorasi.panel(garis: AppColors.border),
      child: Row(
        children: [
          // thumbnail gambar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 60,
              height: 60,
              child: adaGambar
                  ? AppImageView(imagePath: prov.gambar!, fit: BoxFit.cover)
                  : Container(
                      color: AppColors.surfaceMuted,
                      child: const Center(
                        child: Icon(Icons.landscape_rounded, color: AppColors.textMuted, size: 28),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),

          // informasi teks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (pulau != null)
                  Text(
                    'PULAU ${pulau.nama.toUpperCase()}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                      letterSpacing: 0.8,
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  prov.nama,
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (prov.julukan.isNotEmpty)
                  Text(
                    prov.julukan,
                    style: AppTypography.caption(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // tombol aksi
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.primary),
            onSelected: (aksi) {
              if (aksi == 'galeri') {
                _unggahDariGaleri(prov);
              } else if (aksi == 'url') {
                _inputUrlManual(prov);
              } else if (aksi == 'hapus') {
                _hapusGambar(prov);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'galeri',
                child: Row(
                  children: [
                    Icon(Icons.photo_library_rounded, size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Pilih dari Galeri'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'url',
                child: Row(
                  children: [
                    Icon(Icons.link_rounded, size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Tautkan URL'),
                  ],
                ),
              ),
              if (adaGambar)
                const PopupMenuItem(
                  value: 'hapus',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Kembalikan ke Default', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
