import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/wilayah_nusantara.dart';
import '../../../core/widgets/app_bar_halaman.dart';
import '../../../core/widgets/kartu_hasil.dart';
import '../../../core/widgets/kotak_pencarian.dart';
import '../../../core/widgets/pesan_kosong.dart';
import 'package:renjana/features/jelajah/data/models/hasil_jelajah_model.dart';
import 'package:renjana/app/routes/navigasi_arsip.dart';
import 'package:renjana/features/wilayah/data/repositories/wilayah_repository.dart';
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
      appBar: AppBarHalaman(judul: labelKategoriArsip(widget.kunciKategori)),
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
                      style: AppTypography.eyebrow(
                        fontSize: 10.5,
                        color: AppColors.primaryDark,
                        letterSpacing: 1.4,
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
