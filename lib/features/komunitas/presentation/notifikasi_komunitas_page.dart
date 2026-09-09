import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/navigation.dart';
import '../../../core/storage/preference_handler.dart';
import '../data/models/notifikasi_model.dart';
import '../data/repositories/komunitas_repository.dart';
import 'detail_diskusi_page.dart';
import 'detail_jawaban_page.dart';
import 'widgets/teks_dengan_mention.dart';

// halaman notifikasi khusus komunitas (tag dan reply)
class NotifikasiKomunitasPage extends StatefulWidget {
  const NotifikasiKomunitasPage({super.key});

  @override
  State<NotifikasiKomunitasPage> createState() =>
      _NotifikasiKomunitasPageState();
}

class _NotifikasiKomunitasPageState extends State<NotifikasiKomunitasPage> {
  final KomunitasRepository _repository = KomunitasRepository();

  List<NotifikasiKomunitasModel> _daftarNotifikasi = [];
  int _jumlahBelumDibaca = 0;
  bool _isLoading = true;
  String _filterTerpilih = 'semua';

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  // muat data notifikasi
  Future<void> _muatData() async {
    setState(() => _isLoading = true);

    final username = PreferenceHandler.userUsername;
    final userId = PreferenceHandler.userId;
    final nama = PreferenceHandler.userName;
    final target = username.isNotEmpty ? username : nama;

    final hasil = await _repository.getDaftarNotifikasi(
      targetIdentifier: target,
      targetUserId: userId,
      filterTipe:
          _filterTerpilih == 'semua' || _filterTerpilih == 'belum_dibaca'
          ? null
          : _filterTerpilih,
      hanyaBelumDibaca: _filterTerpilih == 'belum_dibaca',
    );

    final unread = await _repository.getJumlahNotifikasiBelumDibaca(
      targetIdentifier: target,
      targetUserId: userId,
    );

    if (!mounted) return;
    setState(() {
      _daftarNotifikasi = hasil;
      _jumlahBelumDibaca = unread;
      _isLoading = false;
    });
  }

  // tandai semua dibaca
  Future<void> _tandaiSemuaDibaca() async {
    final username = PreferenceHandler.userUsername;
    final userId = PreferenceHandler.userId;
    final nama = PreferenceHandler.userName;
    final target = username.isNotEmpty ? username : nama;

    await _repository.tandaiSemuaNotifikasiDibaca(
      targetIdentifier: target,
      targetUserId: userId,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Semua notifikasi ditandai sudah dibaca',
          style: GoogleFonts.plusJakartaSans(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
      ),
    );

    await _muatData();
  }

  // buka target notifikasi
  Future<void> _bukaNotifikasi(NotifikasiKomunitasModel notif) async {
    if (notif.id != null && !notif.sudahDibaca) {
      await _repository.tandaiNotifikasiDibaca(notif.id!);
    }

    if (!mounted) return;

    if (notif.isThreadBalasan && notif.indukJawabanId != null) {
      final diskusi = await _repository.getDiskusiById(notif.diskusiId);
      if (diskusi != null && mounted) {
        await context.push(
          DetailJawabanPage(jawabanId: notif.indukJawabanId!, diskusi: diskusi),
        );
      }
    } else {
      await context.push(DetailDiskusiPage(diskusiId: notif.diskusiId));
    }

    if (!mounted) return;
    await _muatData();
  }

  // hapus notifikasi
  Future<void> _hapusNotifikasi(NotifikasiKomunitasModel notif) async {
    if (notif.id == null) return;
    await _repository.hapusNotifikasi(notif.id!);
    if (!mounted) return;
    setState(() {
      _daftarNotifikasi.removeWhere((item) => item.id == notif.id);
    });
  }

  // format waktu relatif
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifikasi Komunitas',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_daftarNotifikasi.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.done_all_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              tooltip: 'Tandai Semua Dibaca',
              onPressed: _tandaiSemuaDibaca,
            ),
        ],
      ),
      body: Column(
        children: [
          // baris tab filter efisien
          _buildFilterBar(),

          // daftar notifikasi
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _daftarNotifikasi.isEmpty
                ? _buildPesanKosong()
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _muatData,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
                      itemCount: _daftarNotifikasi.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final notif = _daftarNotifikasi[index];
                        return _buildItemNotifikasi(notif);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // bilah filter kategori notifikasi
  Widget _buildFilterBar() {
    final opsi = [
      {'key': 'semua', 'label': 'Semua'},
      {
        'key': 'belum_dibaca',
        'label': _jumlahBelumDibaca > 0
            ? 'Belum Dibaca ($_jumlahBelumDibaca)'
            : 'Belum Dibaca',
      },
      {'key': 'tag', 'label': 'Tag (@)'},
      {'key': 'balas', 'label': 'Balasan'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: opsi.map((item) {
            final key = item['key']!;
            final label = item['label']!;
            final isActive = _filterTerpilih == key;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () {
                  if (_filterTerpilih != key) {
                    setState(() => _filterTerpilih = key);
                    _muatData();
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                      color: isActive ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // kartu item notifikasi
  Widget _buildItemNotifikasi(NotifikasiKomunitasModel notif) {
    final isUnread = !notif.sudahDibaca;

    return Dismissible(
      key: ValueKey('notif_${notif.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 18),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) => _hapusNotifikasi(notif),
      child: GestureDetector(
        onTap: () => _bukaNotifikasi(notif),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUnread
                ? AppColors.primaryLight.withValues(alpha: 0.18)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isUnread ? AppColors.primary : AppColors.border,
              width: isUnread ? 1.2 : 0.8,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ikon tipe notifikasi
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: notif.isTag
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.primaryDark.withValues(alpha: 0.12),
                ),
                child: Icon(
                  notif.isTag
                      ? Icons.alternate_email_rounded
                      : (notif.isThreadBalasan
                            ? Icons.reply_rounded
                            : Icons.chat_bubble_outline_rounded),
                  size: 18,
                  color: notif.isTag
                      ? AppColors.primary
                      : AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 12),

              // isi pesan notifikasi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // pengirim dan aksi
                    Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                color: AppColors.textPrimary,
                              ),
                              children: [
                                TextSpan(
                                  text: notif.pengirimNama,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: notif.isTag
                                      ? ' menyebut Anda di komentar'
                                      : (notif.isThreadBalasan
                                            ? ' membalas komentar Anda'
                                            : ' menanggapi diskusi Anda'),
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isUnread) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),

                    // konteks topik diskusi
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppColors.borderLight,
                          width: 0.7,
                        ),
                      ),
                      child: Text(
                        'Diskusi: ${notif.judulDiskusi}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // cuplikan isi tanggapan dengan highlight mention
                    TeksDenganMention(
                      teks: notif.cuplikanTeks,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // waktu
                    Text(
                      _formatWaktu(notif.dibuatPada),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // tampilan kosong
  Widget _buildPesanKosong() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight.withValues(alpha: 0.3),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 34,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Notifikasi',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _filterTerpilih == 'belum_dibaca'
                  ? 'Semua notifikasi sudah Anda baca.'
                  : 'Notifikasi akan muncul saat seseorang membalas atau me-mention Anda di komunitas.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
