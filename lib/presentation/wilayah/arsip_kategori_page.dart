import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/wilayah_nusantara.dart';
import '../../core/extensions/navigation.dart';
import '../../core/widgets/kartu_hasil.dart';
import '../../core/widgets/kotak_pencarian.dart';
import '../../core/widgets/pesan_kosong.dart';
import '../../data/models/hasil_jelajah_model.dart';
import '../../data/repositories/wilayah_repository.dart';
import '../navigasi_arsip.dart';
import 'kategori_arsip.dart';

// Daftar penuh satu kategori arsip dalam satu provinsi.
class ArsipKategoriPage extends StatefulWidget {
  final Provinsi provinsi;
  final String kunciKategori; // 'SEJARAH' atau kode kategori budaya

  const ArsipKategoriPage({
    super.key,
    required this.provinsi,
    required this.kunciKategori,
  });

  @override
  State<ArsipKategoriPage> createState() => _ArsipKategoriPageState();
}

class _ArsipKategoriPageState extends State<ArsipKategoriPage> {
  final WilayahRepository _wilayahRepository = WilayahRepository();
  final TextEditingController _controller = TextEditingController();

  List<HasilJelajah> _semua = [];
  String _query = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _muatData() async {
    final daftar = await _wilayahRepository.arsipProvinsi(widget.provinsi.nama);
    if (!mounted) return;
    setState(() {
      _semua = daftar
          .where((item) => kunciKategoriArsip(item) == widget.kunciKategori)
          .toList();
      _isLoading = false;
    });
  }

  List<HasilJelajah> get _tersaring => saringArsip(_semua, _query);

  @override
  Widget build(BuildContext context) {
    final hasil = _tersaring;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          labelKategoriArsip(widget.kunciKategori),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.headingSmall().copyWith(fontSize: 18),
        ),
        shape: const Border(
          bottom: BorderSide(color: AppColors.primary, width: 0.8),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.provinsi.nama.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    KotakPencarian(
                      controller: _controller,
                      petunjuk: 'Cari di kategori ini…',
                      onChanged: (nilai) => setState(() => _query = nilai),
                      onBersihkan: () {
                        _controller.clear();
                        setState(() => _query = '');
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : hasil.isEmpty
                    ? PesanKosong(
                        pesan: _query.trim().isEmpty
                            ? 'Belum ada arsip pada kategori ini di '
                                  '${widget.provinsi.nama}.'
                            : 'Tidak ada hasil untuk "${_query.trim()}".',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
                        itemCount: hasil.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, index) => KartuHasil(
                          item: hasil[index],
                          onTap: () async {
                            await bukaHasilJelajah(context, hasil[index]);
                            if (!mounted) return;
                            await _muatData();
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
}
