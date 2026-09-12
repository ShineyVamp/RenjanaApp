import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dekorasi.dart';
import '../../../core/extensions/navigation.dart';
import '../../../core/storage/preference_handler.dart';
import '../../../core/storage/user_session.dart';
import 'package:renjana/features/budaya/data/repositories/budaya_repository.dart';
import 'package:renjana/features/sejarah/data/repositories/sejarah_repository.dart';
import '../../budaya/presentation/detail_budaya_page.dart';
import '../../sejarah/presentation/detail_sejarah_page.dart';
import 'package:renjana/features/komunitas/data/models/komunitas_model.dart';
import 'package:renjana/features/komunitas/data/repositories/komunitas_repository.dart';
import 'widgets/dialog_lapor.dart';
import 'widgets/avatar_pengguna.dart';
import 'widgets/badge_penulis.dart';
import 'widgets/teks_dengan_mention.dart';
import 'widgets/panel_saran_mention.dart';
import 'detail_jawaban_page.dart';
import 'profil_pengguna_lain_page.dart';

class DetailDiskusiPage extends StatefulWidget {
  final int diskusiId;
  final DiskusiModel? initialDiskusi;

  const DetailDiskusiPage({
    super.key,
    required this.diskusiId,
    this.initialDiskusi,
  });

  @override
  State<DetailDiskusiPage> createState() => _DetailDiskusiPageState();
}

class _DetailDiskusiPageState extends State<DetailDiskusiPage> {
  final KomunitasRepository _repository = KomunitasRepository();
  final TextEditingController _jawabanController = TextEditingController();
  final FocusNode _jawabanFocusNode = FocusNode();

  DiskusiModel? _diskusi;
  List<JawabanModel> _daftarJawaban = [];
  List<String> _semuaKandidat = [];
  List<Map<String, String>> _saranPengguna = [];
  int _indexAtSaatIni = -1;
  bool _isLoading = true;
  bool _isSubmitting = false;

  StreamSubscription<List<JawabanModel>>? _jawabanSub;

  // section siklus hidup
  @override
  void initState() {
    super.initState();
    if (widget.initialDiskusi != null) {
      _diskusi = widget.initialDiskusi;
      _isLoading = false;
    }
    _jawabanSub = _repository
        .streamDaftarJawaban(widget.diskusiId)
        .listen((list) {
      if (!mounted) return;
      setState(() {
        _daftarJawaban = list;
        _isLoading = false;
      });
    });
    _muatData();
  }

  @override
  void dispose() {
    _jawabanSub?.cancel();
    _jawabanFocusNode.dispose();
    _jawabanController.dispose();
    super.dispose();
  }

  // section nama prioritas mention
  List<String> _ambilNamaPrioritas() {
    final list = <String>[];
    if (_diskusi != null) {
      if (_diskusi!.penulis.isNotEmpty) list.add(_diskusi!.penulis);
      if (_diskusi!.username != null && _diskusi!.username!.isNotEmpty) {
        list.add(_diskusi!.username!);
      }
    }
    for (final j in _daftarJawaban) {
      if (j.penulis.isNotEmpty && !list.contains(j.penulis)) {
        list.add(j.penulis);
      }
      if (j.username != null &&
          j.username!.isNotEmpty &&
          !list.contains(j.username)) {
        list.add(j.username!);
      }
    }
    for (final k in _semuaKandidat) {
      if (!list.contains(k)) list.add(k);
    }
    return list;
  }

  // section pengetikan tag mention
  void _onJawabanChanged(String text) {
    final sel = _jawabanController.selection;
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
    final text = _jawabanController.text;
    final atIndex = _indexAtSaatIni;
    final cursor = _jawabanController.selection.baseOffset;
    if (atIndex >= 0 && atIndex <= text.length) {
      final beforeAt = text.substring(0, atIndex);
      final afterCursor =
          cursor <= text.length && cursor >= atIndex
              ? text.substring(cursor)
              : text.substring(atIndex);
      final newText = '$beforeAt@$nama $afterCursor';
      _jawabanController.value = TextEditingValue(
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
    _jawabanFocusNode.requestFocus();
  }

  // section sisipkan tag
  void _tambahTag(String nama) {
    final tag = '@$nama ';
    final text = _jawabanController.text;
    final sel = _jawabanController.selection;
    if (sel.isValid && sel.baseOffset >= 0) {
      final before = text.substring(0, sel.baseOffset);
      final after = text.substring(sel.baseOffset);
      final spasi = before.isNotEmpty && !before.endsWith(' ') ? ' ' : '';
      final newText = '$before$spasi$tag$after';
      _jawabanController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: (before + spasi + tag).length,
        ),
      );
    } else {
      final spasi = text.isNotEmpty && !text.endsWith(' ') ? ' ' : '';
      _jawabanController.text = '$text$spasi$tag';
      _jawabanController.selection = TextSelection.collapsed(
        offset: _jawabanController.text.length,
      );
    }
    _jawabanFocusNode.requestFocus();
  }

  // section muat data
  Future<void> _muatData() async {
    final futures = await Future.wait([
      _repository.getDiskusiById(widget.diskusiId),
      _repository.getSemuaNamaPengguna(),
    ]);
    final diskusi = futures[0] as DiskusiModel?;
    final semuaNama = futures[1] as List<String>;
    if (!mounted) return;
    setState(() {
      if (diskusi != null) _diskusi = diskusi;
      _semuaKandidat = semuaNama;
      _isLoading = false;
    });
  }

  // section toggle suara diskusi
  Future<void> _toggleSuaraDiskusi() async {
    if (_diskusi == null || _diskusi!.id == null) return;
    final lama = _diskusi!;
    final wasVoted = lama.suaraSaya > 0;
    final delta = wasVoted ? -1 : 1;
    setState(() {
      _diskusi = lama.copyWith(
        suaraSaya: wasVoted ? 0 : 1,
        jumlahSuara: (lama.jumlahSuara + delta).clamp(0, 999999),
      );
    });
    await _repository.toggleSuara('diskusi', lama.id!);
  }

  // section toggle suara jawaban
  Future<void> _toggleSuaraJawaban(JawabanModel jawaban) async {
    if (jawaban.id == null) return;
    final wasVoted = jawaban.suaraSaya > 0;
    final delta = wasVoted ? -1 : 1;
    setState(() {
      final idx = _daftarJawaban.indexWhere((j) => j.id == jawaban.id);
      if (idx != -1) {
        _daftarJawaban[idx] = _daftarJawaban[idx].copyWith(
          suaraSaya: wasVoted ? 0 : 1,
          jumlahSuara: (_daftarJawaban[idx].jumlahSuara + delta).clamp(0, 999999),
        );
      }
    });
    await _repository.toggleSuara('jawaban', jawaban.id!);
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

  bool get _isAdmin =>
      PreferenceHandler.isAdmin ||
      (PreferenceHandler.user?.isAdminAccount ?? false);

  Future<void> _hapusDiskusi() async {
    if (_diskusi == null) return;
    final setuju = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(
              Icons.delete_forever_rounded,
              color: AppColors.error,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Hapus Diskusi?',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'Postingan ini beserta seluruh komentarnya akan dihapus secara permanen dari komunitas.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            height: 1.5,
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

    if (setuju == true && _diskusi!.id != null) {
      await _repository.hapusDiskusi(_diskusi!.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Diskusi berhasil dihapus',
            style: GoogleFonts.plusJakartaSans(color: Colors.white),
          ),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> _hapusJawaban(JawabanModel jawaban) async {
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

    if (setuju == true && jawaban.id != null) {
      await _repository.hapusJawaban(jawaban.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Komentar berhasil dihapus',
            style: GoogleFonts.plusJakartaSans(color: Colors.white),
          ),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
      await _muatData();
    }
  }

  Future<void> _kirimJawaban() async {
    final teks = _jawabanController.text.trim();
    if (teks.isEmpty || _isSubmitting) return;

    if (teks.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Komentar terlalu pendek (minimal 3 karakter).',
            style: GoogleFonts.plusJakartaSans(color: Colors.white),
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final userId = idAkunAktif;
    if (!_isAdmin && userId > 0) {
      final jawabanTerakhir = await _repository.getJawabanTerakhirUser(
        userId,
        widget.diskusiId,
      );
      if (jawabanTerakhir != null) {
        if (jawabanTerakhir.isi.trim().toLowerCase() ==
            teks.toLowerCase()) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Anda baru saja mengirim komentar yang sama.',
                style: GoogleFonts.plusJakartaSans(color: Colors.white),
              ),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        final selisihDetik =
            DateTime.now().difference(jawabanTerakhir.dibuatPada).inSeconds;
        const cooldown = 45;
        if (selisihDetik < cooldown) {
          final sisaDetik = cooldown - selisihDetik;
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Tunggu $sisaDetik detik sebelum mengirim komentar berikutnya.',
                style: GoogleFonts.plusJakartaSans(color: Colors.white),
              ),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
      }
    }

    setState(() => _isSubmitting = true);
    final user = PreferenceHandler.user;
    final nama = user?.nama.isNotEmpty == true
        ? user!.nama
        : PreferenceHandler.userName;

    await _repository.tambahJawaban(
      JawabanModel(
        diskusiId: widget.diskusiId,
        userId: userId,
        penulis: nama.isNotEmpty ? nama : 'Pengguna Renjana',
        isi: teks,
        dibuatPada: DateTime.now(),
      ),
    );

    _jawabanController.clear();
    setState(() {
      _isSubmitting = false;
      _saranPengguna = [];
    });
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
    if (diskusi == null) {
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
        ),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final userId = PreferenceHandler.userId;
    final userName = PreferenceHandler.user?.nama ?? '';
    final bisaHapusDiskusi =
        _isAdmin ||
        ((userId > 0 && diskusi.userId == userId) ||
            (userName.isNotEmpty &&
                diskusi.penulis.toLowerCase() ==
                    userName.toLowerCase()));

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
          if (bisaHapusDiskusi)
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 22,
              ),
              tooltip: 'Hapus Diskusi',
              onPressed: _hapusDiskusi,
            ),
          IconButton(
            icon: const Icon(
              Icons.flag_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
            tooltip: 'Laporkan Diskusi',
            onPressed: () {
              tampilkanDialogLapor(
                context,
                targetTipe: 'diskusi',
                targetId: diskusi.id.toString(),
                kontenTeks: '${diskusi.judul} — ${diskusi.isi}',
              );
            },
          ),
        ],
      ),
      body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // section konten utama
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: AppDekorasi.panel(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  AvatarPengguna(
                                    fotoUrl: diskusi.fotoProfil,
                                    nama: diskusi.penulis,
                                    radius: 16,
                                    onTap: () => _bukaProfilPengguna(
                                      userId: diskusi.userId,
                                      username: diskusi.username,
                                      nama: diskusi.penulis,
                                      fotoProfil: diskusi.fotoProfil,
                                      role: diskusi.role,
                                      gelar: diskusi.gelar,
                                      badgePilihan: diskusi.badgePilihan,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () => _bukaProfilPengguna(
                                            userId: diskusi.userId,
                                            username: diskusi.username,
                                            nama: diskusi.penulis,
                                            fotoProfil: diskusi.fotoProfil,
                                            role: diskusi.role,
                                            gelar: diskusi.gelar,
                                            badgePilihan: diskusi.badgePilihan,
                                          ),
                                          behavior: HitTestBehavior.opaque,
                                          child: Text(
                                            diskusi.penulis,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        BadgePenulis(
                                          role: diskusi.role,
                                          gelar: diskusi.gelar,
                                          badgePilihan: diskusi.badgePilihan,
                                          waktuTeks:
                                              _formatWaktu(diskusi.dibuatPada),
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
                               TeksDenganMention(
                                teks: diskusi.isi,
                                kandidatNama: _ambilNamaPrioritas(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  height: 1.55,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // section tautan arsip
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

                              // section aksi diskusi
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: _toggleSuaraDiskusi,
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
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
                                            size: 14,
                                            color: diskusi.suaraSaya > 0
                                                ? AppColors.primary
                                                : AppColors.textMuted,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${diskusi.jumlahSuara}',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11.5,
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
                                  const SizedBox(width: 8),
                                  Container(
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
                                          '${_daftarJawaban.length} Tanggapan',
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
                                  // section tag penulis
                                  GestureDetector(
                                    onTap: () {
                                      final targetTag = (diskusi.username != null &&
                                              diskusi.username!.isNotEmpty)
                                          ? diskusi.username!
                                          : diskusi.penulis
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
                                        border:
                                            Border.all(color: AppColors.border),
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
                        const SizedBox(height: 22),

                        // section daftar tanggapan
                        Text(
                          'Tanggapan (${_daftarJawaban.length})',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (_isLoading && _daftarJawaban.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          )
                        else if (_daftarJawaban.isEmpty)
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
                              final bisaHapusJwb = _isAdmin ||
                                  (userId > 0 && jwb.userId == userId) ||
                                  (userName.isNotEmpty &&
                                      jwb.penulis.toLowerCase() ==
                                          userName.toLowerCase());
                              return GestureDetector(
                                onTap: () async {
                                  await context.push(
                                    DetailJawabanPage(
                                      jawabanId: jwb.id!,
                                      diskusi: diskusi,
                                      initialKomentar: jwb,
                                    ),
                                  );
                                  _muatData();
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: AppDekorasi.panel(),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          AvatarPengguna(
                                            fotoUrl: jwb.fotoProfil,
                                            nama: jwb.penulis,
                                            radius: 12,
                                            onTap: () => _bukaProfilPengguna(
                                              userId: jwb.userId,
                                              username: jwb.username,
                                              nama: jwb.penulis,
                                              fotoProfil: jwb.fotoProfil,
                                              role: jwb.role,
                                              gelar: jwb.gelar,
                                              badgePilihan: jwb.badgePilihan,
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
                                                    userId: jwb.userId,
                                                    username: jwb.username,
                                                    nama: jwb.penulis,
                                                    fotoProfil: jwb.fotoProfil,
                                                    role: jwb.role,
                                                    gelar: jwb.gelar,
                                                    badgePilihan: jwb.badgePilihan,
                                                  ),
                                                  behavior: HitTestBehavior.opaque,
                                                  child: Text(
                                                    jwb.penulis,
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
                                                  role: jwb.role,
                                                  gelar: jwb.gelar,
                                                  badgePilihan: jwb.badgePilihan,
                                                  waktuTeks: _formatWaktu(
                                                      jwb.dibuatPada),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (bisaHapusJwb) ...[
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
                                                  _hapusJawaban(jwb),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      // section teks komentar
                                      TeksDenganMention(
                                        teks: jwb.isi,
                                        kandidatNama: _ambilNamaPrioritas(),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () => _toggleSuaraJawaban(jwb),
                                            behavior: HitTestBehavior.opaque,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isJwbVoted
                                                    ? AppColors.primary.withAlpha(25)
                                                    : AppColors.surface,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: isJwbVoted
                                                      ? AppColors.primary
                                                      : AppColors.border,
                                                ),
                                              ),
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
                                                    style:
                                                        GoogleFonts.plusJakartaSans(
                                                      fontSize: 11.5,
                                                      fontWeight: FontWeight.bold,
                                                      color: isJwbVoted
                                                          ? AppColors.primary
                                                          : AppColors.textPrimary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // section balas komentar
                                          GestureDetector(
                                            onTap: () async {
                                              await context.push(
                                                DetailJawabanPage(
                                                  jawabanId: jwb.id!,
                                                  diskusi: diskusi,
                                                  initialKomentar: jwb,
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
                                                    'Balas (${jwb.jumlahBalasan})',
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
                                              final targetTag = (jwb.username !=
                                                          null &&
                                                      jwb.username!.isNotEmpty)
                                                  ? jwb.username!
                                                  : jwb.penulis
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

                // section input jawaban
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
                            focusNode: _jawabanFocusNode,
                            onChanged: _onJawabanChanged,
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
