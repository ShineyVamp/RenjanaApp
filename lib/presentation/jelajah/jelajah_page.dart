import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/wilayah_nusantara.dart';
import '../../core/extensions/navigation.dart';
import '../../core/widgets/app_image.dart';
import '../../data/models/hasil_jelajah_model.dart';
import '../../data/repositories/jelajah_repository.dart';
import '../../services/riwayat_handler.dart';
import '../detail/detail_budaya_page.dart';
import '../detail/detail_sejarah_page.dart';

class JelajahPage extends StatefulWidget {
  // Membuka tab Peta dari kartu "Telusuri lewat peta".
  final VoidCallback? onBukaPeta;

  const JelajahPage({super.key, this.onBukaPeta});

  @override
  State<JelajahPage> createState() => _JelajahPageState();
}

class _JelajahPageState extends State<JelajahPage> {
  final JelajahRepository _repository = JelajahRepository();
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
    final dibuka = await _repository.ambilDariRiwayat(
      RiwayatHandler.dibuka,
      batas: RiwayatHandler.batasDibuka,
    );
    if (!mounted) return;
    setState(() {
      _terakhirDicari = RiwayatHandler.pencarian;
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
    // Ketikan cepat bisa menyelesaikan pencarian tidak berurutan, jadi hasil
    // yang sudah basi dibuang.
    if (!mounted || kataKunci != _query) return;
    setState(() {
      _hasil = hasil;
      _sedangMencari = false;
    });
  }

  // Riwayat dicatat saat pencarian dikirim, bukan tiap ketikan.
  Future<void> _simpanKeRiwayat() async {
    final kunci = _query.trim();
    if (kunci.isEmpty) return;
    await RiwayatHandler.catatPencarian(kunci);
    if (!mounted) return;
    setState(() => _terakhirDicari = RiwayatHandler.pencarian);
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

    await context.push(
      item.jenis == JenisArsip.sejarah
          ? DetailSejarahPage(sejarah: item.sejarah!)
          : DetailBudayaPage(budaya: item.budaya!),
    );
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
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.primary, width: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jelajah',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 32,
              color: AppColors.textPrimary,
              height: 1.1,
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: 80,
            height: 2.5,
            color: AppColors.primary,
            margin: const EdgeInsets.only(top: 5, bottom: 14),
          ),
          Container(
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
        ],
      ),
    );
  }

  // tampilan awal: riwayat pencarian, pintasan peta, arsip terakhir dibuka
  Widget _buildBerandaJelajah() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabelSeksi('TERAKHIR DICARI'),
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

        _buildLabelSeksi('TERAKHIR DIBUKA'),
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
                    child: _KartuHasil(
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
            child: _KartuHasil(item: item, onTap: () => _bukaArsip(item)),
          ),
        ),
      ],
    );
  }

  Widget _buildLabelSeksi(String teks) {
    return Text(
      teks,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
        color: AppColors.primary,
      ),
    );
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

class _KartuHasil extends StatelessWidget {
  final HasilJelajah item;
  final VoidCallback onTap;

  const _KartuHasil({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.borderPrimary),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 104,
              height: 140,
              child: AspectRatio(
                aspectRatio: 1,
                child: AppImageView(imagePath: item.gambar, fit: BoxFit.cover),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        _Lencana(teks: item.kodeTag, warna: AppColors.primary),
                        if (item.isDestinasi) ...[
                          const SizedBox(width: 6),
                          const _Lencana(
                            teks: 'DESTINASI',
                            warna: AppColors.accentBudaya,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.judul,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 19,
                        color: AppColors.textPrimary,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.sub,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.meta.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.primaryDark,
                      ),
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

class _Lencana extends StatelessWidget {
  final String teks;
  final Color warna;

  const _Lencana({required this.teks, required this.warna});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      color: warna,
      child: Text(
        teks,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.7,
          color: Colors.white,
        ),
      ),
    );
  }
}
