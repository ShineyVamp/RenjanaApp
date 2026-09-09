import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dekorasi.dart';
import '../../../../core/storage/preference_handler.dart';
import '../../../../core/storage/user_session.dart';
import '../data/models/komunitas_model.dart';
import '../data/repositories/komunitas_repository.dart';
import 'widgets/badge_penulis.dart';
import 'widgets/teks_dengan_mention.dart';
import 'widgets/panel_saran_mention.dart';

// halaman detail jawaban dan thread balasan
class DetailJawabanPage extends StatefulWidget {
  final int jawabanId;
  final DiskusiModel diskusi;

  const DetailJawabanPage({
    super.key,
    required this.jawabanId,
    required this.diskusi,
  });

  @override
  State<DetailJawabanPage> createState() => _DetailJawabanPageState();
}

class _DetailJawabanPageState extends State<DetailJawabanPage> {
  final KomunitasRepository _repository = KomunitasRepository();
  final TextEditingController _balasanController = TextEditingController();
  final FocusNode _balasanFocusNode = FocusNode();

  JawabanModel? _komentar;
  List<JawabanModel> _daftarBalasan = [];
  List<String> _semuaKandidat = [];
  List<Map<String, String>> _saranPengguna = [];
  int _indexAtSaatIni = -1;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  @override
  void dispose() {
    _balasanFocusNode.dispose();
    _balasanController.dispose();
    super.dispose();
  }

  // daftar nama prioritas untuk mention
  List<String> _ambilNamaPrioritas() {
    final list = <String>[];
    if (widget.diskusi.penulis.isNotEmpty) {
      list.add(widget.diskusi.penulis);
    }
    if (widget.diskusi.username != null &&
        widget.diskusi.username!.isNotEmpty &&
        !list.contains(widget.diskusi.username)) {
      list.add(widget.diskusi.username!);
    }
    if (_komentar != null) {
      if (_komentar!.penulis.isNotEmpty && !list.contains(_komentar!.penulis)) {
        list.add(_komentar!.penulis);
      }
      if (_komentar!.username != null &&
          _komentar!.username!.isNotEmpty &&
          !list.contains(_komentar!.username)) {
        list.add(_komentar!.username!);
      }
    }
    for (final b in _daftarBalasan) {
      if (b.penulis.isNotEmpty && !list.contains(b.penulis)) {
        list.add(b.penulis);
      }
      if (b.username != null &&
          b.username!.isNotEmpty &&
          !list.contains(b.username)) {
        list.add(b.username!);
      }
    }
    for (final k in _semuaKandidat) {
      if (!list.contains(k)) list.add(k);
    }
    return list;
  }

  // deteksi pengetikan @ untuk memunculkan saran tag
  void _onBalasanChanged(String text) {
    final sel = _balasanController.selection;
    if (!sel.isValid || sel.baseOffset <= 0) {
      if (_saranPengguna.isNotEmpty) {
        setState(() => _saranPengguna = []);
      }
      return;
    }

    final textBeforeCursor = text.substring(0, sel.baseOffset);
    final lastAtIndex = textBeforeCursor.lastIndexOf('@');
    if (lastAtIndex != -1) {
      final validPrefix = lastAtIndex == 0 ||
          RegExp(r'\s').hasMatch(textBeforeCursor[lastAtIndex - 1]);
      final query = textBeforeCursor.substring(lastAtIndex + 1);
      if (validPrefix && !query.contains(RegExp(r'\s'))) {
        _indexAtSaatIni = lastAtIndex;
        _cariSaranTag(query);
        return;
      }
    }

    if (_saranPengguna.isNotEmpty) {
      setState(() => _saranPengguna = []);
    }
  }

  // cari saran tag dari repositori
  Future<void> _cariSaranTag(String query) async {
    final hasil = await _repository.cariPenggunaTag(
      kataKunci: query,
      namaPrioritas: _ambilNamaPrioritas(),
    );
    if (!mounted) return;
    setState(() {
      _saranPengguna = hasil;
    });
  }

  // pilih tag dari panel saran
  void _pilihTagPengguna(String nama) {
    final text = _balasanController.text;
    final atIndex = _indexAtSaatIni;
    final cursor = _balasanController.selection.baseOffset;
    if (atIndex >= 0 && atIndex <= text.length) {
      final beforeAt = text.substring(0, atIndex);
      final afterCursor =
          cursor <= text.length && cursor >= atIndex
              ? text.substring(cursor)
              : text.substring(atIndex);
      final newText = '$beforeAt@$nama $afterCursor';
      _balasanController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: '$beforeAt@$nama '.length,
        ),
      );
    } else {
      _tambahTag(nama);
    }
    setState(() {
      _saranPengguna = [];
    });
    _balasanFocusNode.requestFocus();
  }

  // sisipkan tag pengguna ke input
  void _tambahTag(String nama) {
    final tag = '@$nama ';
    final text = _balasanController.text;
    final sel = _balasanController.selection;
    if (sel.isValid && sel.baseOffset >= 0) {
      final before = text.substring(0, sel.baseOffset);
      final after = text.substring(sel.baseOffset);
      final spasi = before.isNotEmpty && !before.endsWith(' ') ? ' ' : '';
      final newText = '$before$spasi$tag$after';
      _balasanController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: (before + spasi + tag).length,
        ),
      );
    } else {
      final spasi = text.isNotEmpty && !text.endsWith(' ') ? ' ' : '';
      _balasanController.text = '$text$spasi$tag';
      _balasanController.selection = TextSelection.collapsed(
        offset: _balasanController.text.length,
      );
    }
    _balasanFocusNode.requestFocus();
  }

  // muat data
  Future<void> _muatData() async {
    final komentar = await _repository.getJawabanById(widget.jawabanId);
    final balasan = await _repository.getDaftarBalasan(widget.jawabanId);
    final semuaNama = await _repository.getSemuaNamaPengguna();
    if (!mounted) return;
    setState(() {
      _komentar = komentar;
      _daftarBalasan = balasan;
      _semuaKandidat = semuaNama;
      _isLoading = false;
    });
  }

  bool get _isAdmin =>
      PreferenceHandler.isAdmin ||
      (PreferenceHandler.user?.isAdminAccount ?? false);

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

  // toggle suara komentar utama
  Future<void> _toggleSuaraKomentar() async {
    if (_komentar?.id == null) return;
    await _repository.toggleSuara('jawaban', _komentar!.id!);
    await _muatData();
  }

  // toggle suara balasan
  Future<void> _toggleSuaraBalasan(JawabanModel balasan) async {
    if (balasan.id == null) return;
    await _repository.toggleSuara('jawaban', balasan.id!);
    await _muatData();
  }

  // hapus balasan
  Future<void> _hapusBalasan(JawabanModel balasan) async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              'Hapus Balasan?',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'Balasan ini akan dihapus secara permanen.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Hapus',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (setuju == true && balasan.id != null) {
      await _repository.hapusJawaban(balasan.id!);
      if (!mounted) return;
      await _muatData();
    }
  }

  // kirim balasan
  Future<void> _kirimBalasan() async {
    final teks = _balasanController.text.trim();
    if (teks.isEmpty || _isSubmitting || _komentar == null) return;

    if (teks.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Balasan terlalu pendek.',
            style: GoogleFonts.plusJakartaSans(color: Colors.white),
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final user = PreferenceHandler.user;
    final nama = user?.nama.isNotEmpty == true
        ? user!.nama
        : PreferenceHandler.userName;

    await _repository.tambahJawaban(
      JawabanModel(
        diskusiId: widget.diskusi.id!,
        indukId: _komentar!.id,
        balasKe: _komentar!.penulis,
        userId: idAkunAktif,
        penulis: nama.isNotEmpty ? nama : 'Pengguna Renjana',
        isi: teks,
        dibuatPada: DateTime.now(),
      ),
    );

    _balasanController.clear();
    setState(() {
      _isSubmitting = false;
      _saranPengguna = [];
    });
    await _muatData();
  }

  @override
  Widget build(BuildContext context) {
    final komentar = _komentar;
    final currentUserId = idAkunAktif;
    final currentUserName = PreferenceHandler.userName.trim().toLowerCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Text(
          'Balasan Komentar',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading || komentar == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // banner konteks diskusi induk
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.forum_outlined,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Diskusi: ${widget.diskusi.judul}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // kartu komentar utama yang difokuskan
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: AppDekorasi.panel(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor:
                                        AppColors.primaryDark.withAlpha(30),
                                    child: Text(
                                      komentar.penulis.isNotEmpty
                                          ? komentar.penulis[0].toUpperCase()
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
                                          komentar.penulis,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        // role ditaruh di bawah nama
                                        BadgePenulis(
                                          role: komentar.role,
                                          gelar: komentar.gelar,
                                          badgePilihan: komentar.badgePilihan,
                                          waktuTeks: _formatWaktu(
                                            komentar.dibuatPada,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // teks isi komentar utama dengan sorotan mention
                              TeksDenganMention(
                                teks: komentar.isi,
                                kandidatNama: _ambilNamaPrioritas(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  height: 1.55,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // aksi komentar utama
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: _toggleSuaraKomentar,
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: komentar.suaraSaya > 0
                                            ? AppColors.primary.withAlpha(25)
                                            : AppColors.surface,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: komentar.suaraSaya > 0
                                              ? AppColors.primary
                                              : AppColors.border,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            komentar.suaraSaya > 0
                                                ? Icons.arrow_upward_rounded
                                                : Icons.arrow_upward_outlined,
                                            size: 15,
                                            color: komentar.suaraSaya > 0
                                                ? AppColors.primary
                                                : AppColors.textMuted,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            'Dukung (${komentar.jumlahSuara})',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.bold,
                                              color: komentar.suaraSaya > 0
                                                  ? AppColors.primary
                                                  : AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.borderLight,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.chat_bubble_outline_rounded,
                                          size: 14,
                                          color: AppColors.textMuted,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          '${_daftarBalasan.length} Balasan',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // tombol tag penulis utama
                                  GestureDetector(
                                    onTap: () {
                                      final targetTag = (komentar.username !=
                                                  null &&
                                              komentar.username!.isNotEmpty)
                                          ? komentar.username!
                                          : komentar.penulis
                                              .replaceAll(RegExp(r'\s+'), '_')
                                              .toLowerCase();
                                      _tambahTag(targetTag);
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppColors.borderLight,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.alternate_email_rounded,
                                            size: 13,
                                            color: AppColors.primary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Tag',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primaryDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // judul seksi balasan
                        Text(
                          'Balasan (${_daftarBalasan.length})',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // daftar balasan anak
                        if (_daftarBalasan.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: AppDekorasi.panel(),
                            child: Center(
                              child: Text(
                                'Belum ada balasan. Jadilah yang pertama membalas!',
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
                            itemCount: _daftarBalasan.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final b = _daftarBalasan[index];
                              final isBVoted = b.suaraSaya > 0;
                              final bisaHapus = _isAdmin ||
                                  (currentUserId > 0 && b.userId == currentUserId) ||
                                  (b.penulis.toLowerCase() == currentUserName);

                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: AppDekorasi.panel(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 13,
                                          backgroundColor: AppColors.primaryDark
                                              .withAlpha(20),
                                          child: Text(
                                            b.penulis.isNotEmpty
                                                ? b.penulis[0].toUpperCase()
                                                : 'P',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primaryDark,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                b.penulis,
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              // role ditaruh di bawah nama
                                              BadgePenulis(
                                                role: b.role,
                                                gelar: b.gelar,
                                                badgePilihan: b.badgePilihan,
                                                waktuTeks: _formatWaktu(
                                                  b.dibuatPada,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (bisaHapus) ...[
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline_rounded,
                                              size: 16,
                                              color: AppColors.error,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            tooltip: 'Hapus Balasan',
                                            onPressed: () => _hapusBalasan(b),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // teks isi balasan
                                    TeksDenganMention(
                                      teks: b.isi,
                                      kandidatNama: _ambilNamaPrioritas(),
                                    ),
                                    const SizedBox(height: 8),

                                    // tombol aksi balasan
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () => _toggleSuaraBalasan(b),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                isBVoted
                                                    ? Icons.arrow_upward_rounded
                                                    : Icons.arrow_upward_outlined,
                                                size: 14,
                                                color: isBVoted
                                                    ? AppColors.primary
                                                    : AppColors.textMuted,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${b.jumlahSuara}',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: isBVoted
                                                      ? AppColors.primary
                                                      : AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        // tombol tag pengguna
                                        GestureDetector(
                                          onTap: () {
                                            final targetTag = (b.username !=
                                                        null &&
                                                    b.username!.isNotEmpty)
                                                ? b.username!
                                                : b.penulis
                                                    .replaceAll(
                                                        RegExp(r'\s+'), '_')
                                                    .toLowerCase();
                                            _tambahTag(targetTag);
                                          },
                                          behavior: HitTestBehavior.opaque,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.alternate_email_rounded,
                                                size: 13,
                                                color: AppColors.textMuted,
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                'Tag',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
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

                // panel saran mention saat mengetik @
                PanelSaranMention(
                  daftarPengguna: _saranPengguna,
                  onPilih: _pilihTagPengguna,
                ),

                // input balasan di bagian bawah
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
                            controller: _balasanController,
                            focusNode: _balasanFocusNode,
                            onChanged: _onBalasanChanged,
                            maxLines: null,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _kirimBalasan(),
                            decoration: InputDecoration(
                              hintText: 'Balas @${komentar.penulis}...',
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
                          onPressed: _isSubmitting ? null : _kirimBalasan,
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
