import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dekorasi.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/kuis_kategori.dart';
import '../../../core/widgets/app_bar_halaman.dart';
import '../../../core/widgets/grid_horizontal.dart';
import '../../../core/widgets/kotak_pencarian.dart';
import '../../../core/widgets/pesan_kosong.dart';
import 'package:renjana/features/quiz/data/models/tema_kuis_model.dart';
import 'package:renjana/features/quiz/data/repositories/quiz_repository.dart';
import 'mulai_kuis_page.dart';
import 'widgets/kartu_tema_kuis.dart';

// Isi satu kategori kuis, dengan tiga cara main: acak dari seluruh kategori,
// gabungan satu penyaring, atau satu tema. Kartu tema dikelompokkan menurut
// penanda sub-kategorinya: budaya per kategori budaya, kedaerahan per provinsi
// dengan pulau sebagai penyaring.
class KategoriKuisPage extends StatefulWidget {
  final String kategori;

  const KategoriKuisPage({super.key, required this.kategori});

  @override
  State<KategoriKuisPage> createState() => _KategoriKuisPageState();
}

class _KategoriKuisPageState extends State<KategoriKuisPage> {
  final QuizRepository _quizRepository = QuizRepository();
  final TextEditingController _controller = TextEditingController();

  static const String _semuaPenyaring = 'SEMUA';
  static const double _lebarKartu = 370;
  static const double _tinggiKartu = 140;

  List<TemaKuis> _semuaTema = [];
  int _totalSoal = 0;
  String _query = '';
  String _penyaring = _semuaPenyaring;
  bool _isLoading = true;

  bool get _berkelompok => kategoriPunyaSubKategori(widget.kategori);

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
    final soal = await _quizRepository.getQuizByKategori(widget.kategori);
    if (!mounted) return;
    setState(() {
      _semuaTema = TemaKuis.dariSoal(soal);
      _totalSoal = soal.length;
      _isLoading = false;
    });
  }

  // Kunci kelompok satu tema: nilai sub-kategori yang dikenali katalog, atau
  // string kosong untuk kelompok "Lainnya".
  String _kunciKelompok(TemaKuis tema) =>
      opsiSubKategoriDariNilai(widget.kategori, tema.subKategori)?.nilai ?? '';

  List<TemaKuis> _saringTema() {
    final kunci = _query.trim().toLowerCase();
    return _semuaTema.where((tema) {
      if (_penyaring != _semuaPenyaring &&
          indukSubKategori(widget.kategori, tema.subKategori) != _penyaring) {
        return false;
      }
      if (kunci.isEmpty) return true;

      final ladang = [
        tema.tema,
        tema.contohSoal,
        labelSubKategori(widget.kategori, tema.subKategori),
        ...tema.soal.map((s) => s.soal),
      ].join(' ').toLowerCase();
      return ladang.contains(kunci);
    }).toList();
  }

  // Mengelompokkan tema per sub-kategori, urut sesuai katalog dengan
  // "Lainnya" di posisi terakhir.
  List<MapEntry<String, List<TemaKuis>>> _kelompokkan(List<TemaKuis> tema) {
    if (!_berkelompok) {
      return tema.isEmpty ? const [] : [MapEntry('', tema)];
    }

    final isi = <String, List<TemaKuis>>{};
    for (final t in tema) {
      isi.putIfAbsent(_kunciKelompok(t), () => []).add(t);
    }

    return [
      for (final opsi in opsiSubKategori(widget.kategori))
        if (isi.containsKey(opsi.nilai)) MapEntry(opsi.nilai, isi[opsi.nilai]!),
      if (isi.containsKey('')) MapEntry('', isi['']!),
    ];
  }

  // Daftar chip penyaring, hanya induk yang punya tema.
  List<String> _daftarPenyaring() {
    if (!_berkelompok) return const [];

    final tersedia = _semuaTema
        .map((t) => indukSubKategori(widget.kategori, t.subKategori))
        .toSet();
    return [
      for (final induk in daftarIndukSubKategori(widget.kategori))
        if (tersedia.contains(induk)) induk,
      if (tersedia.contains(subKategoriLainnya)) subKategoriLainnya,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final kelompok = _kelompokkan(_saringTema());
    final penyaring = _daftarPenyaring();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarHalaman(judul: 'Kuis ${widget.kategori}'),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 32),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildPanelKategori(),
                    ),
                    const SizedBox(height: 26),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildPemisah(),
                    ),
                    const SizedBox(height: 16),

                    if (_semuaTema.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildPencarian(penyaring),
                      ),

                    if (_semuaTema.isEmpty)
                      PesanKosong(
                        pesan:
                            'Belum ada tema kuis pada kategori '
                            '${widget.kategori}.',
                        ikon: Icons.quiz_outlined,
                      )
                    else if (kelompok.isEmpty)
                      PesanKosong(
                        pesan: _query.trim().isEmpty
                            ? 'Tidak ada tema pada penyaring ini.'
                            : 'Tidak ada tema untuk "${_query.trim()}".',
                        ikon: Icons.search_off_rounded,
                      )
                    else
                      ...kelompok.map((e) => _buildKelompok(e.key, e.value)),
                  ],
                ),
        ),
      ),
    );
  }

  // section cara main pertama: acak dari seluruh kategori
  Widget _buildPanelKategori() {
    final jumlahTema = _semuaTema.length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppDekorasi.panel(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shuffle_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Kuis Seluruh Kategori',
                  style: AppTypography.editorialHeading().copyWith(
                    fontSize: 19,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            'Soal diambil acak dari semua tema ${widget.kategori}, dan Anda '
            'menentukan sendiri berapa soal yang dikerjakan.',
            style: AppTypography.bodySmall().copyWith(height: 1.4),
          ),
          const SizedBox(height: 12),

          Text(
            '$_totalSoal SOAL · $jumlahTema TEMA',
            style: AppTypography.eyebrow(fontSize: 11, letterSpacing: 0.8),
          ),
          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: const RoundedRectangleBorder(),
              ),
              onPressed: _totalSoal == 0
                  ? null
                  : () => tampilkanSheetKuisKategori(context, widget.kategori),
              child: Text(
                'Mulai Kuis ${widget.kategori}',
                style: AppTypography.buttonText().copyWith(fontSize: 13.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // batas antara dua cara main
  Widget _buildPemisah() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'ATAU PILIH SATU TEMA',
            style: AppTypography.eyebrow(
              fontSize: 10.5,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }

  // section pencarian tema dan chip penyaring
  Widget _buildPencarian(List<String> penyaring) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KotakPencarian(
          controller: _controller,
          petunjuk: 'Cari tema ${widget.kategori}…',
          onChanged: (nilai) => setState(() => _query = nilai),
          onBersihkan: () {
            _controller.clear();
            setState(() => _query = '');
          },
        ),
        if (penyaring.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildChip(_semuaPenyaring, 'Semua'),
                ...penyaring.map((induk) => _buildChip(induk, induk)),
              ],
            ),
          ),
        ],
        _buildTombolPenyaring(),
      ],
    );
  }

  // Menggabungkan seluruh tema di bawah satu penyaring jadi satu kuis; inilah
  // pencampuran tingkat pulau untuk kategori kedaerahan.
  Widget _buildTombolPenyaring() {
    if (_penyaring == _semuaPenyaring) return const SizedBox.shrink();

    final tema = _semuaTema
        .where(
          (t) => indukSubKategori(widget.kategori, t.subKategori) == _penyaring,
        )
        .toList();
    if (tema.length < 2) return const SizedBox.shrink();

    final soal = [for (final t in tema) ...t.soal];

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: const RoundedRectangleBorder(),
          ),
          onPressed: () => mulaiKuisGabungan(
            context,
            judul: 'Kuis $_penyaring',
            kategori: widget.kategori,
            soal: soal,
          ),
          icon: const Icon(
            Icons.shuffle_rounded,
            size: 17,
            color: AppColors.primary,
          ),
          label: Text(
            'Main semua tema $_penyaring · ${soal.length} soal',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String nilai, String label) {
    final terpilih = _penyaring == nilai;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _penyaring = nilai),
        behavior: HitTestBehavior.opaque,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: terpilih ? AppColors.primary : AppColors.surface,
            borderRadius: AppDekorasi.radiusKecil,
            border: Border.all(
              color: terpilih ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
              color: terpilih ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  // satu kelompok sub-kategori beserta grid temanya
  Widget _buildKelompok(String kunci, List<TemaKuis> tema) {
    final jumlahSoal = tema.fold<int>(0, (total, t) => total + t.jumlahSoal);

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_berkelompok)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    labelSubKategori(widget.kategori, kunci),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.editorialHeading().copyWith(
                      fontSize: 19,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${tema.length} tema · $jumlahSoal soal',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridHorizontal(
              key: ValueKey('$kunci-${tema.length}-$_query'),
              jumlahItem: tema.length,
              lebarKartu: _lebarKartu,
              tinggiKartu: _tinggiKartu,
              builder: (index) => KartuTemaKuis(
                tema: tema[index],
                onTap: () => mulaiKuisTema(context, tema[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
