import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/wilayah_nusantara.dart';
import '../../core/widgets/header_halaman.dart';
import '../../core/widgets/kartu_hasil.dart';
import '../../data/models/hasil_jelajah_model.dart';
import '../../data/repositories/jelajah_repository.dart';
import '../../data/repositories/riwayat_repository.dart';
import '../navigasi_arsip.dart';

class JelajahPage extends StatefulWidget {
  // Membuka tab Peta dari kartu "Telusuri lewat peta".
  final VoidCallback? onBukaPeta;

  const JelajahPage({super.key, this.onBukaPeta});

  @override
  State<JelajahPage> createState() => _JelajahPageState();
}

class _JelajahPageState extends State<JelajahPage> {
  final JelajahRepository _repository = JelajahRepository();
  final RiwayatRepository _riwayatRepository = RiwayatRepository();
  final TextEditingController _controller = TextEditingController();

  String _query = '';
  List<HasilJelajah> _hasil = [];
  List<HasilJelajah> _terakhirDibuka = [];
  List<String> _terakhirDicari = [];
  bool _sedangMencari = false;

  bool get _adaQuery => _query.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _muatRiwayat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _muatRiwayat() async {
    final refs = await _riwayatRepository.dibuka(
      batas: RiwayatRepository.batasDibuka,
    );
    final dicari = await _riwayatRepository.pencarian(
      batas: RiwayatRepository.batasPencarian,
    );
    final dibuka = await _repository.ambilDariRiwayat(
      refs,
      batas: RiwayatRepository.batasDibuka,
    );
    if (!mounted) return;
    setState(() {
      _terakhirDicari = dicari;
      _terakhirDibuka = dibuka;
    });
  }

  Future<void> _jalankanPencarian(String kataKunci) async {
    setState(() {
      _query = kataKunci;
      _sedangMencari = kataKunci.trim().isNotEmpty;
    });

    if (kataKunci.trim().isEmpty) {
      setState(() {
        _hasil = [];
        _sedangMencari = false;
      });
      return;
    }

    final hasil = await _repository.cari(kataKunci);
    // buang hasil yang bukan milik kata kunci terakhir
    if (!mounted || kataKunci != _query) return;
    setState(() {
      _hasil = hasil;
      _sedangMencari = false;
    });
  }

  // Mengirim pencarian dan mencatatnya ke riwayat.
  Future<void> _simpanKeRiwayat() async {
    final kunci = _query.trim();
    if (kunci.isEmpty) return;
    await _riwayatRepository.catatPencarian(kunci);
    final dicari = await _riwayatRepository.pencarian(
      batas: RiwayatRepository.batasPencarian,
    );
    if (!mounted) return;
    setState(() => _terakhirDicari = dicari);
  }

  void _pakaiKataKunci(String kataKunci) {
    _controller.text = kataKunci;
    _controller.selection = TextSelection.collapsed(offset: kataKunci.length);
    _jalankanPencarian(kataKunci);
  }

  void _bersihkanQuery() {
    _controller.clear();
    _jalankanPencarian('');
  }

  Future<void> _bukaArsip(HasilJelajah item) async {
    await _simpanKeRiwayat();
    if (!mounted) return;

    await bukaHasilJelajah(context, item);
    if (!mounted) return;
    await _muatRiwayat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: _adaQuery
                    ? _buildHasilPencarian()
                    : _buildBerandaJelajah(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // section header: judul + kotak pencarian
  Widget _buildHeader() {
    return HeaderHalaman(
      judul: 'Jelajah',
      bawah: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.borderPrimary),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: _jalankanPencarian,
                onSubmitted: (_) => _simpanKeRiwayat(),
                textInputAction: TextInputAction.search,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'Cari keris, Borobudur, proklamasi…',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
            if (_adaQuery)
              GestureDetector(
                onTap: _bersihkanQuery,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // tampilan awal: riwayat pencarian, pintasan peta, arsip terakhir dibuka
  Widget _buildBerandaJelajah() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabelSeksi(
          'TERAKHIR DICARI',
          onHapus: _terakhirDicari.isEmpty
              ? null
              : () => _konfirmasiHapus(
                  judul: 'Hapus riwayat pencarian?',
                  pesan:
                      'Semua kata kunci yang pernah dicari akan dihapus dari '
                      'akun ini.',
                  aksi: _riwayatRepository.hapusPencarian,
                ),
        ),
        const SizedBox(height: 10),
        if (_terakhirDicari.isEmpty)
          const _PesanInfo(
            icon: Icons.search_off_rounded,
            pesan: 'Belum ada pencarian yang dilakukan.',
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _terakhirDicari
                .map(
                  (kata) => GestureDetector(
                    onTap: () => _pakaiKataKunci(kata),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        kata,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

        _buildPemisah(),

        _buildLabelSeksi('TELUSURI LEWAT PETA'),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: widget.onBukaPeta,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.borderPrimary),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.map_outlined,
                    size: 26,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$jumlahProvinsi provinsi, satu peta',
                        style: AppTypography.editorialHeading().copyWith(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Buka Peta Nusantara dan pilih pulau untuk melihat '
                        'arsip daerahnya.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          height: 1.45,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        _buildPemisah(),

        _buildLabelSeksi(
          'TERAKHIR DIBUKA',
          onHapus: _terakhirDibuka.isEmpty
              ? null
              : () => _konfirmasiHapus(
                  judul: 'Hapus riwayat arsip?',
                  pesan:
                      'Daftar arsip yang pernah dibuka akan dikosongkan. '
                      'Arsipnya sendiri tidak terhapus.',
                  aksi: _riwayatRepository.hapusDibuka,
                ),
        ),
        const SizedBox(height: 12),
        if (_terakhirDibuka.isEmpty)
          const _PesanInfo(
            icon: Icons.history_rounded,
            pesan: 'Belum ada arsip yang dibuka.',
          )
        else
          Column(
            children: _terakhirDibuka
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: KartuHasil(
                      item: item,
                      onTap: () => _bukaArsip(item),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  // tampilan saat ada kata kunci
  Widget _buildHasilPencarian() {
    if (_sedangMencari) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_hasil.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 10),
        child: Column(
          children: [
            const Icon(
              Icons.search_rounded,
              size: 46,
              color: AppColors.surfaceMuted,
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak ada hasil untuk "${_query.trim()}"',
              textAlign: TextAlign.center,
              style: AppTypography.labelBold(fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text(
              'Coba kata kunci lain, atau telusuri lewat Peta Nusantara.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_hasil.length} hasil untuk "${_query.trim()}"',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        ..._hasil.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: KartuHasil(item: item, onTap: () => _bukaArsip(item)),
          ),
        ),
      ],
    );
  }

  // [onHapus] diisi untuk seksi yang isinya riwayat dan bisa dikosongkan.
  Widget _buildLabelSeksi(String teks, {VoidCallback? onHapus}) {
    final label = Text(
      teks,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
        color: AppColors.primary,
      ),
    );

    if (onHapus == null) return label;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        label,
        GestureDetector(
          onTap: onHapus,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.delete_outline_rounded,
                  size: 15,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 3),
                Text(
                  'Hapus',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Konfirmasi sebelum satu jenis riwayat dikosongkan.
  Future<void> _konfirmasiHapus({
    required String judul,
    required String pesan,
    required Future<void> Function() aksi,
  }) async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(judul, style: AppTypography.headingSmall()),
        content: Text(pesan, style: AppTypography.bodyMedium()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(
              'Batal',
              style: AppTypography.labelBold(
                fontSize: 13,
              ).copyWith(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(
              'Hapus',
              style: AppTypography.labelBold(
                fontSize: 13,
              ).copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (setuju != true) return;
    await aksi();
    if (!mounted) return;
    await _muatRiwayat();
  }

  Widget _buildPemisah() {
    return Container(
      height: 1,
      color: AppColors.border,
      margin: const EdgeInsets.symmetric(vertical: 22),
    );
  }
}

// kotak pesan saat sebuah seksi masih kosong
class _PesanInfo extends StatelessWidget {
  final IconData icon;
  final String pesan;

  const _PesanInfo({required this.icon, required this.pesan});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.surfaceMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              pesan,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
