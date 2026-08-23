import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dekorasi.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/app_bar_halaman.dart';
import '../../core/widgets/pesan_kosong.dart';
import '../../data/models/hasil_kuis_model.dart';
import '../../data/repositories/hasil_kuis_repository.dart';

// Rekor per tema dan daftar percobaan kuis milik akun yang sedang login.
class RiwayatKuisPage extends StatefulWidget {
  const RiwayatKuisPage({super.key});

  @override
  State<RiwayatKuisPage> createState() => _RiwayatKuisPageState();
}

class _RiwayatKuisPageState extends State<RiwayatKuisPage> {
  final HasilKuisRepository _repository = HasilKuisRepository();

  // Percobaan dimuat sepotong demi sepotong; tanpa ini daftar akan menarik
  // seluruh riwayat pengguna yang rajin berkuis.
  static const int _ukuranHalaman = 20;

  List<HasilKuis> _percobaan = [];
  List<HasilKuis> _rekor = [];
  // Yang masih tersimpan utuh; percobaan lama sudah dipangkas.
  int _tersimpan = 0;

  // Seluruh percobaan sepanjang masa, diambil dari rekap.
  int _totalPercobaan = 0;
  bool _isLoading = true;
  bool _memuatLagi = false;

  bool get _adaLagi => _percobaan.length < _tersimpan;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    final percobaan = await _repository.semua(batas: _ukuranHalaman);
    final rekor = await _repository.rekorPerTema();
    final ringkas = await _repository.ringkasan();
    final tersimpan = await _repository.jumlahPercobaan();
    if (!mounted) return;

    final urut = rekor.values.toList()
      ..sort((a, b) {
        if (a.persen != b.persen) return b.persen.compareTo(a.persen);
        return a.tema.toLowerCase().compareTo(b.tema.toLowerCase());
      });

    setState(() {
      _percobaan = percobaan;
      _rekor = urut;
      _totalPercobaan = ringkas.percobaan;
      _tersimpan = tersimpan;
      _isLoading = false;
    });
  }

  Future<void> _muatLagi() async {
    if (_memuatLagi || !_adaLagi) return;
    setState(() => _memuatLagi = true);

    final tambahan = await _repository.semua(
      batas: _ukuranHalaman,
      lewati: _percobaan.length,
    );
    if (!mounted) return;
    setState(() {
      _percobaan = [..._percobaan, ...tambahan];
      _memuatLagi = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarHalaman(judul: 'Rekor Kuis'),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : _percobaan.isEmpty
              ? const PesanKosong(
                  pesan:
                      'Belum ada kuis yang diselesaikan. Rekor akan muncul '
                      'di sini setelah kuis pertama Anda.',
                  ikon: Icons.emoji_events_outlined,
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _muatData,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                    children: [
                      if (_rekor.isNotEmpty) ...[
                        _buildJudulSeksi(
                          'Rekor Terbaik',
                          '${_rekor.length} tema',
                        ),
                        const SizedBox(height: 10),
                        ..._rekor.map(_buildBarisRekor),
                        const SizedBox(height: 26),
                      ],

                      _buildJudulSeksi(
                        'Percobaan Terakhir',
                        '${_percobaan.length} dari $_tersimpan',
                      ),
                      if (_totalPercobaan > _tersimpan)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Dari $_totalPercobaan kuis yang pernah Anda '
                            'kerjakan, $_tersimpan terakhir disimpan '
                            'rinciannya. Rekor dan ketepatan keseluruhan '
                            'tetap menghitung semuanya.',
                            style: AppTypography.caption(
                              fontSize: 10.5,
                              height: 1.35,
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                      ..._percobaan.map(_buildBarisPercobaan),
                      if (_adaLagi) _buildTombolMuatLagi(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTombolMuatLagi() {
    final sisa = _tersimpan - _percobaan.length;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: const RoundedRectangleBorder(),
          ),
          onPressed: _memuatLagi ? null : _muatLagi,
          child: Text(
            _memuatLagi ? 'Memuat…' : 'Muat $_ukuranHalaman lagi · sisa $sisa',
            style: AppTypography.labelBold(
              fontSize: 12.5,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJudulSeksi(String judul, String keterangan) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            judul,
            style: AppTypography.editorialHeading().copyWith(fontSize: 19),
          ),
        ),
        Text(
          keterangan.toUpperCase(),
          style: AppTypography.eyebrow(fontSize: 10.5, letterSpacing: 0.8),
        ),
      ],
    );
  }

  // Satu tema beserta capaian terbaiknya; yang sempurna diberi aksen emas.
  Widget _buildBarisRekor(HasilKuis rekor) {
    final warna = rekor.sempurna ? AppColors.gold : AppColors.border;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: AppDekorasi.panelCapaian(warna, menonjol: rekor.sempurna),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rekor.tema,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${rekor.benar}/${rekor.jumlahSoal} benar · ${rekor.waktuTerbaca}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${rekor.persen}%',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 22,
                  color: rekor.sempurna
                      ? AppColors.gold
                      : AppColors.textPrimary,
                  height: 1,
                ),
              ),
              if (rekor.sempurna)
                Text(
                  'SEMPURNA',
                  style: AppTypography.eyebrow(
                    fontSize: 9,
                    color: AppColors.gold,
                    letterSpacing: 1,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarisPercobaan(HasilKuis hasil) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: AppDekorasi.barisDaftar,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasil.judul,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_tanggal(hasil.selesaiPada)} · ${hasil.waktuTerbaca}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${hasil.benar}/${hasil.jumlahSoal}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  static const List<String> _namaBulan = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  String _tanggal(DateTime waktu) {
    final jam = waktu.hour.toString().padLeft(2, '0');
    final menit = waktu.minute.toString().padLeft(2, '0');
    return '${waktu.day} ${_namaBulan[waktu.month - 1]} · $jam.$menit';
  }
}
