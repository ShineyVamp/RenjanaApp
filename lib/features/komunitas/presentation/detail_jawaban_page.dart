import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dekorasi.dart';
import '../../../../core/extensions/navigation.dart';
import '../../../../core/storage/preference_handler.dart';
import '../../../../core/storage/user_session.dart';
import '../data/models/komunitas_model.dart';
import '../data/repositories/komunitas_repository.dart';
import 'profil_pengguna_lain_page.dart';
import 'widgets/avatar_pengguna.dart';
import 'widgets/badge_penulis.dart';
import 'widgets/teks_dengan_mention.dart';
import 'widgets/panel_saran_mention.dart';

class DetailJawabanPage extends StatefulWidget {
  final int jawabanId;
  final DiskusiModel diskusi;
  final JawabanModel? initialKomentar;

  const DetailJawabanPage({
    super.key,
    required this.jawabanId,
    required this.diskusi,
    this.initialKomentar,
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

  StreamSubscription<List<JawabanModel>>? _balasanSub;

  // section siklus hidup
  @override
  void initState() {
    super.initState();
    if (widget.initialKomentar != null) {
      _komentar = widget.initialKomentar;
      _isLoading = false;
    }
    _balasanSub = _repository
        .streamDaftarBalasan(widget.jawabanId)
        .listen((list) {
      if (!mounted) return;
      setState(() {
        _daftarBalasan = list;
        _isLoading = false;
      });
    });
    _muatData();
  }

  @override
  void dispose() {
    _balasanSub?.cancel();
    _balasanFocusNode.dispose();
    _balasanController.dispose();
    super.dispose();
  }

  // section nama prioritas mention
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

  // section pengetikan tag mention
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

  // section cari saran tag
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

  // section pilih tag saran
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

  // section sisipkan tag
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

  // section muat data
  Future<void> _muatData() async {
    final futures = await Future.wait([
      _repository.getJawabanById(widget.jawabanId),
      _repository.getSemuaNamaPengguna(),
    ]);
    final komentar = futures[0] as JawabanModel?;
    final semuaNama = futures[1] as List<String>;
    if (!mounted) return;
    setState(() {
      if (komentar != null) _komentar = komentar;
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

  // section toggle suara komentar utama
  Future<void> _toggleSuaraKomentar() async {
    if (_komentar?.id == null) return;
    final lama = _komentar!;
    final wasVoted = lama.suaraSaya > 0;
    final delta = wasVoted ? -1 : 1;
    setState(() {
      _komentar = lama.copyWith(
        suaraSaya: wasVoted ? 0 : 1,
        jumlahSuara: (lama.jumlahSuara + delta).clamp(0, 999999),
      );
    });
    await _repository.toggleSuara('jawaban', lama.id!);
  }

  // section toggle suara balasan
  Future<void> _toggleSuaraBalasan(JawabanModel balasan) async {
    if (balasan.id == null) return;
    final wasVoted = balasan.suaraSaya > 0;
    final delta = wasVoted ? -1 : 1;
    setState(() {
      final idx = _daftarBalasan.indexWhere((b) => b.id == balasan.id);
      if (idx != -1) {
        _daftarBalasan[idx] = _daftarBalasan[idx].copyWith(
          suaraSaya: wasVoted ? 0 : 1,
          jumlahSuara: (_daftarBalasan[idx].jumlahSuara + delta).clamp(0, 999999),
        );
      }
    });
    await _repository.toggleSuara('jawaban', balasan.id!);
  }

  // section buka profil pengguna
  void _bukaProfilPengguna({
    required int userId,
    String? username,
    required String nama,
    String? fotoProfil,
    String role = 'user',
    String gelar = 'Pengelana Budaya',
    List<String> badgePilihan = const [],
  }) {
    context.push(
      ProfilPenggunaLainPage(
        userId: userId,
        username: username,
        nama: nama,
        fotoProfil: fotoProfil,
        role: role,
        gelar: gelar,
        badgePilihan: badgePilihan,
      ),
    );
  }

  // section hapus komentar utama
  Future<void> _hapusKomentarUtama(JawabanModel komentar) async {
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
              'Hapus Komentar?',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'Komentar ini akan dihapus secara permanen.',
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

    if (setuju == true && komentar.id != null) {
      await _repository.hapusJawaban(komentar.id!);
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  // section hapus balasan
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

  // section kirim balasan
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
    if (komentar == null) {
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
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final currentUserId = idAkunAktif;
    final currentUserName = PreferenceHandler.userName.trim().toLowerCase();
    final bisaHapusKomentar =
        _isAdmin ||
        (currentUserId > 0 && komentar.userId == currentUserId) ||
        (komentar.penulis.toLowerCase() == currentUserName);

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
      body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // section banner konteks
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.forum_outlined,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  komentar.isBalasan &&
                                          komentar.balasKe != null &&
                                          komentar.balasKe!.isNotEmpty
                                      ? 'Membalas @${komentar.balasKe} di "${widget.diskusi.judul}"'
                                      : 'Diskusi: ${widget.diskusi.judul}',
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

                        // section kartu komentar utama
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: AppDekorasi.panel(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AvatarPengguna(
                                    fotoUrl: komentar.fotoProfil,
                                    nama: komentar.penulis,
                                    radius: 14,
                                    onTap: () => _bukaProfilPengguna(
                                      userId: komentar.userId,
                                      username: komentar.username,
                                      nama: komentar.penulis,
                                      fotoProfil: komentar.fotoProfil,
                                      role: komentar.role,
                                      gelar: komentar.gelar,
                                      badgePilihan: komentar.badgePilihan,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () => _bukaProfilPengguna(
                                            userId: komentar.userId,
                                            username: komentar.username,
                                            nama: komentar.penulis,
                                            fotoProfil: komentar.fotoProfil,
                                            role: komentar.role,
                                            gelar: komentar.gelar,
                                            badgePilihan: komentar.badgePilihan,
                                          ),
                                          behavior: HitTestBehavior.opaque,
                                          child: Text(
                                            komentar.penulis,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
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
                                  if (bisaHapusKomentar) ...[
                                    const SizedBox(width: 4),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        size: 16,
                                        color: AppColors.error,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      tooltip: 'Hapus Komentar',
                                      onPressed: () =>
                                          _hapusKomentarUtama(komentar),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 8),

                              // section teks komentar utama
                              TeksDenganMention(
                                teks: komentar.isi,
                                kandidatNama: _ambilNamaPrioritas(),
                              ),
                              const SizedBox(height: 8),

                              // section aksi komentar utama
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: _toggleSuaraKomentar,
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
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
                                            size: 14,
                                            color: komentar.suaraSaya > 0
                                                ? AppColors.primary
                                                : AppColors.textMuted,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${komentar.jumlahSuara}',
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
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.chat_bubble_outline_rounded,
                                          size: 13,
                                          color: AppColors.textMuted,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${_daftarBalasan.length} Balasan',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // section tag penulis utama
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
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppColors.border,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.alternate_email_rounded,
                                            size: 13,
                                            color: AppColors.textMuted,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Tag',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textSecondary,
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

                        // section judul seksi balasan
                        Text(
                          'Balasan (${_daftarBalasan.length})',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // section daftar balasan anak
                        if (_isLoading && _daftarBalasan.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          )
                        else if (_daftarBalasan.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: AppDekorasi.panel(),
                            child: Center(
                              child: Text(
                                'Belum ada balasan. Tulis balasan pertama Anda di bawah!',
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

                              return GestureDetector(
                                onTap: () async {
                                  await context.push(
                                    DetailJawabanPage(
                                      jawabanId: b.id!,
                                      diskusi: widget.diskusi,
                                    ),
                                  );
                                  _muatData();
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: AppDekorasi.panel(),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          AvatarPengguna(
                                            fotoUrl: b.fotoProfil,
                                            nama: b.penulis,
                                            radius: 12,
                                            onTap: () => _bukaProfilPengguna(
                                              userId: b.userId,
                                              username: b.username,
                                              nama: b.penulis,
                                              fotoProfil: b.fotoProfil,
                                              role: b.role,
                                              gelar: b.gelar,
                                              badgePilihan: b.badgePilihan,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                GestureDetector(
                                                  onTap: () => _bukaProfilPengguna(
                                                    userId: b.userId,
                                                    username: b.username,
                                                    nama: b.penulis,
                                                    fotoProfil: b.fotoProfil,
                                                    role: b.role,
                                                    gelar: b.gelar,
                                                    badgePilihan: b.badgePilihan,
                                                  ),
                                                  behavior: HitTestBehavior.opaque,
                                                  child: Text(
                                                    b.penulis,
                                                    style:
                                                        GoogleFonts.plusJakartaSans(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.textPrimary,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
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
                                            const SizedBox(width: 4),
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
                                      if (b.balasKe != null &&
                                          b.balasKe!.isNotEmpty &&
                                          b.balasKe != komentar.penulis) ...[
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.reply_rounded,
                                              size: 13,
                                              color: AppColors.primary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'membalas @${b.balasKe}',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.primaryDark,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                      ],

                                       // section teks isi balasan
                                       TeksDenganMention(
                                        teks: b.isi,
                                        kandidatNama: _ambilNamaPrioritas(),
                                      ),
                                      const SizedBox(height: 8),

                                       // section aksi balasan
                                       Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () => _toggleSuaraBalasan(b),
                                            behavior: HitTestBehavior.opaque,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isBVoted
                                                    ? AppColors.primary.withAlpha(25)
                                                    : AppColors.surface,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: isBVoted
                                                      ? AppColors.primary
                                                      : AppColors.border,
                                                ),
                                              ),
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
                                                      fontSize: 11.5,
                                                      fontWeight: FontWeight.bold,
                                                      color: isBVoted
                                                          ? AppColors.primary
                                                          : AppColors.textPrimary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                           // section balas balasan
                                           GestureDetector(
                                            onTap: () async {
                                              await context.push(
                                                DetailJawabanPage(
                                                  jawabanId: b.id!,
                                                  diskusi: widget.diskusi,
                                                ),
                                              );
                                              _muatData();
                                            },
                                            behavior: HitTestBehavior.opaque,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.surface,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: AppColors.border),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.chat_bubble_outline_rounded,
                                                    size: 13,
                                                    color: AppColors.textMuted,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Balas (${b.jumlahBalasan})',
                                                    style:
                                                        GoogleFonts.plusJakartaSans(
                                                      fontSize: 11.5,
                                                      fontWeight: FontWeight.w600,
                                                      color:
                                                          AppColors.textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                           // section tag pengguna
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
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.surface,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: AppColors.border),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.alternate_email_rounded,
                                                    size: 13,
                                                    color: AppColors.textMuted,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Tag',
                                                    style:
                                                        GoogleFonts.plusJakartaSans(
                                                      fontSize: 11.5,
                                                      fontWeight: FontWeight.w600,
                                                      color:
                                                          AppColors.textSecondary,
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
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                // section panel saran mention
                PanelSaranMention(
                  daftarPengguna: _saranPengguna,
                  onPilih: _pilihTagPengguna,
                ),

                // section input balasan
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
                              hintText: 'Tulis balasan untuk @${komentar.penulis}...',
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
