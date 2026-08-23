import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dekorasi.dart';
import '../../core/extensions/navigation.dart';
import '../../core/widgets/dialog_lapor.dart';
import '../../data/models/komunitas_model.dart';
import '../../data/repositories/budaya_repository.dart';
import '../../data/repositories/komunitas_repository.dart';
import '../../data/repositories/pemilik_akun.dart';
import '../../data/repositories/sejarah_repository.dart';
import '../../services/preference_handler.dart';
import '../detail/detail_budaya_page.dart';
import '../detail/detail_sejarah_page.dart';

class DetailDiskusiPage extends StatefulWidget {
  final int diskusiId;

  const DetailDiskusiPage({super.key, required this.diskusiId});

  @override
  State<DetailDiskusiPage> createState() => _DetailDiskusiPageState();
}

class _DetailDiskusiPageState extends State<DetailDiskusiPage> {
  final KomunitasRepository _repository = KomunitasRepository();
  final TextEditingController _jawabanController = TextEditingController();

  DiskusiModel? _diskusi;
  List<JawabanModel> _daftarJawaban = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  @override
  void dispose() {
    _jawabanController.dispose();
    super.dispose();
  }

  Future<void> _muatData() async {
    final diskusi = await _repository.getDiskusiById(widget.diskusiId);
    final jawaban = await _repository.getDaftarJawaban(widget.diskusiId);
    if (!mounted) return;
    setState(() {
      _diskusi = diskusi;
      _daftarJawaban = jawaban;
      _isLoading = false;
    });
  }

  Future<void> _toggleSuaraDiskusi() async {
    if (_diskusi == null) return;
    await _repository.toggleSuara('diskusi', _diskusi!.id!);
    await _muatData();
  }

  Future<void> _toggleSuaraJawaban(JawabanModel jawaban) async {
    if (jawaban.id == null) return;
    await _repository.toggleSuara('jawaban', jawaban.id!);
    await _muatData();
  }

  Future<void> _kirimJawaban() async {
    final teks = _jawabanController.text.trim();
    if (teks.isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    final user = PreferenceHandler.user;
    final nama = user?.nama.isNotEmpty == true
        ? user!.nama
        : PreferenceHandler.userName;

    await _repository.tambahJawaban(
      JawabanModel(
        diskusiId: widget.diskusiId,
        userId: idAkunAktif,
        penulis: nama.isNotEmpty ? nama : 'Pengguna Renjana',
        isi: teks,
        dibuatPada: DateTime.now(),
      ),
    );

    _jawabanController.clear();
    setState(() => _isSubmitting = false);
    await _muatData();
  }

  Future<void> _bukaArsipTerkait(String kodeTag) async {
    final bersih = kodeTag.trim();
    if (bersih.startsWith('HIS') || bersih.contains('history')) {
      final item = await SejarahRepository().getSejarahByKodeTag(bersih);
      if (item != null && mounted) {
        context.push(DetailSejarahPage(sejarah: item));
        return;
      }
    } else {
      final item = await BudayaRepository().getBudayaByKodeTag(bersih);
      if (item != null && mounted) {
        context.push(DetailBudayaPage(budaya: item));
        return;
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Arsip "$kodeTag" sedang tidak tersedia.'),
        backgroundColor: AppColors.textSecondary,
      ),
    );
  }

  String _formatWaktu(DateTime waktu) {
    final selisih = DateTime.now().difference(waktu);
    if (selisih.inDays > 30) {
      return '${waktu.day}/${waktu.month}/${waktu.year}';
    } else if (selisih.inDays > 0) {
      return '${selisih.inDays}h lalu';
    } else if (selisih.inHours > 0) {
      return '${selisih.inHours}j lalu';
    } else if (selisih.inMinutes > 0) {
      return '${selisih.inMinutes}m lalu';
    } else {
      return 'Baru saja';
    }
  }

  @override
  Widget build(BuildContext context) {
    final diskusi = _diskusi;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Diskusi',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.flag_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
            tooltip: 'Laporkan Diskusi',
            onPressed: () {
              if (diskusi != null) {
                tampilkanDialogLapor(
                  context,
                  targetTipe: 'diskusi',
                  targetId: diskusi.id.toString(),
                  kontenTeks: '${diskusi.judul} — ${diskusi.isi}',
                );
              }
            },
          ),
        ],
      ),
      body: _isLoading || diskusi == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kotak Konten Utama Diskusi
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: AppDekorasi.panel(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor:
                                        AppColors.primaryDark.withAlpha(30),
                                    child: Text(
                                      diskusi.penulis.isNotEmpty
                                          ? diskusi.penulis[0].toUpperCase()
                                          : 'P',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          diskusi.penulis,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          _formatWaktu(diskusi.dibuatPada),
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.primaryLight.withAlpha(50),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      diskusi.kategori,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              Text(
                                diskusi.judul,
                                style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 10),

                              Text(
                                diskusi.isi,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  height: 1.55,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Tautan Arsip
                              if (diskusi.refArsip != null &&
                                  diskusi.refArsip!.trim().isNotEmpty) ...[
                                GestureDetector(
                                  onTap: () =>
                                      _bukaArsipTerkait(diskusi.refArsip!),
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.primary.withAlpha(15),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: AppColors.borderPrimary,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.article_outlined,
                                          color: AppColors.primary,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Arsip Terkait: ${diskusi.refArsip}',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primaryDark,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 13,
                                          color: AppColors.primaryDark,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                              ],

                              // Tombol Upvote Diskusi
                              GestureDetector(
                                onTap: _toggleSuaraDiskusi,
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: diskusi.suaraSaya > 0
                                        ? AppColors.primary.withAlpha(25)
                                        : AppColors.surface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: diskusi.suaraSaya > 0
                                          ? AppColors.primary
                                          : AppColors.border,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        diskusi.suaraSaya > 0
                                            ? Icons.arrow_upward_rounded
                                            : Icons.arrow_upward_outlined,
                                        size: 16,
                                        color: diskusi.suaraSaya > 0
                                            ? AppColors.primary
                                            : AppColors.textMuted,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Dukung (${diskusi.jumlahSuara})',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: diskusi.suaraSaya > 0
                                              ? AppColors.primary
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Bagian Jawaban / Tanggapan
                        Text(
                          'Tanggapan (${_daftarJawaban.length})',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (_daftarJawaban.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: AppDekorasi.panel(),
                            child: Center(
                              child: Text(
                                'Belum ada tanggapan. Tulis tanggapan pertama Anda di bawah!',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _daftarJawaban.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final jwb = _daftarJawaban[index];
                              final isJwbVoted = jwb.suaraSaya > 0;
                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: AppDekorasi.panel(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 12,
                                          backgroundColor: AppColors.primaryDark
                                              .withAlpha(20),
                                          child: Text(
                                            jwb.penulis.isNotEmpty
                                                ? jwb.penulis[0].toUpperCase()
                                                : 'P',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primaryDark,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            jwb.penulis,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          _formatWaktu(jwb.dibuatPada),
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      jwb.isi,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12.5,
                                        height: 1.45,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () => _toggleSuaraJawaban(jwb),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isJwbVoted
                                                ? Icons.arrow_upward_rounded
                                                : Icons.arrow_upward_outlined,
                                            size: 14,
                                            color: isJwbVoted
                                                ? AppColors.primary
                                                : AppColors.textMuted,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${jwb.jumlahSuara}',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: isJwbVoted
                                                  ? AppColors.primary
                                                  : AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                // Kolom Input Jawaban di Bawah
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(color: AppColors.border, width: 0.8),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _jawabanController,
                            maxLines: null,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _kirimJawaban(),
                            decoration: InputDecoration(
                              hintText: 'Tulis tanggapan atau jawaban...',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: AppColors.textMuted,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              filled: true,
                              fillColor: AppColors.background,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide:
                                    const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide:
                                    const BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                )
                              : const Icon(
                                  Icons.send_rounded,
                                  color: AppColors.primary,
                                ),
                          onPressed: _isSubmitting ? null : _kirimJawaban,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
