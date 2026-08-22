import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/extensions/navigation.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/header_halaman.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/bookmark_repository.dart';
import '../../data/repositories/jelajah_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../services/pemilih_gambar.dart';
import '../../services/preference_handler.dart';
import '../../data/repositories/riwayat_repository.dart';
import '../auth/login_page.dart';
import '../bookmark/bookmark_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserRepository _userRepository = UserRepository();
  final BookmarkRepository _bookmarkRepository = BookmarkRepository();
  final JelajahRepository _jelajahRepository = JelajahRepository();
  final RiwayatRepository _riwayatRepository = RiwayatRepository();

  UserSQLModel? _user;
  int _jumlahTersimpan = 0;
  int _jumlahDibuka = 0;
  int _jumlahProvinsi = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    final sesi = PreferenceHandler.user;

    // data terbaru dibaca dari database, bukan dari salinan sesi
    UserSQLModel? user = sesi;
    if (sesi != null && sesi.email.trim().isNotEmpty) {
      user = await _userRepository.getUserByEmail(sesi.email) ?? sesi;
    }

    final bookmark = await _bookmarkRepository.getAllBookmarks();
    final refs = await _riwayatRepository.dibuka();
    final dibuka = await _jelajahRepository.ambilDariRiwayat(refs);
    final provinsi = dibuka
        .map((item) => item.asalProvinsi?.trim().toLowerCase())
        .whereType<String>()
        .where((nama) => nama.isNotEmpty)
        .toSet();

    if (!mounted) return;
    setState(() {
      _user = user;
      _jumlahTersimpan = bookmark.length;
      _jumlahDibuka = refs.length;
      _jumlahProvinsi = provinsi.length;
      _isLoading = false;
    });
  }

  Future<void> _simpanFoto(String? path) async {
    final user = _user;
    if (user == null || user.email.trim().isEmpty) return;

    await _userRepository.perbaruiFotoProfil(user.email, path);
    final diperbarui = user.copyWith(fotoProfil: path, hapusFoto: path == null);
    await PreferenceHandler.saveUser(diperbarui);

    if (!mounted) return;
    setState(() => _user = diperbarui);

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          path == null ? 'Foto profil dihapus' : 'Foto profil diperbarui',
        ),
        duration: const Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _bukaPilihanFoto() {
    final adaFoto = (_user?.fotoProfil ?? '').trim().isNotEmpty;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, color: AppColors.border),
            const SizedBox(height: 14),
            Text('Foto Profil', style: AppTypography.headingSmall()),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.primary,
              ),
              title: Text(
                'Pilih dari galeri',
                style: AppTypography.labelBold(fontSize: 14),
              ),
              onTap: () async {
                Navigator.pop(sheetCtx);
                if (!mounted) return;
                final path = await pilihGambarDariGaleri(context);
                if (path != null) await _simpanFoto(path);
              },
            ),
            if (adaFoto)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                ),
                title: Text(
                  'Hapus foto',
                  style: AppTypography.labelBold(
                    fontSize: 14,
                  ).copyWith(color: AppColors.error),
                ),
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  await _simpanFoto(null);
                },
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final messenger = ScaffoldMessenger.of(context);
    await PreferenceHandler.logOut();
    if (!mounted) return;
    messenger.clearSnackBars();
    context.pushAndRemoveAll(const LoginPage());
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Berhasil logout'),
        duration: Duration(milliseconds: 1200),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _muatData,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildIdentitas(user),
                        const SizedBox(height: 22),
                        _buildStatistik(),
                        const SizedBox(height: 26),
                        _buildMenu(),
                        const SizedBox(height: 26),
                        _buildTombolLogout(),
                        const SizedBox(height: 18),
                        Text(
                          'RENJANA v1.0.0 · ARSIP BUDAYA NUSANTARA',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  // section judul halaman, tepinya diambil alih ListView di sekitarnya
  Widget _buildHeader() => const HeaderHalaman(
    judul: 'Profil',
    garisBawah: false,
    padding: EdgeInsets.zero,
  );

  // section foto, nama, dan email
  Widget _buildIdentitas(UserSQLModel? user) {
    final nama = (user?.nama ?? '').trim().isNotEmpty
        ? user!.nama
        : PreferenceHandler.userName;
    final email = (user?.email ?? '').trim().isNotEmpty
        ? user!.email
        : PreferenceHandler.userEmail;
    final isAdmin = user?.isAdminAccount ?? PreferenceHandler.isAdmin;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAvatar(user, nama),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 26,
                    height: 1.1,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isAdmin ? 'PENGELOLA ARSIP' : 'PENJELAJAH NUSANTARA',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.mail_outline_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        email.isNotEmpty ? email : 'Belum ada email',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Foto profil, atau kotak berisi huruf depan nama bila foto belum ada.
  Widget _buildAvatar(UserSQLModel? user, String nama) {
    final foto = (user?.fotoProfil ?? '').trim();
    final inisial = nama.trim().isEmpty ? '?' : nama.trim()[0].toUpperCase();

    return GestureDetector(
      onTap: _bukaPilihanFoto,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 92,
        height: 92,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: AppColors.primary,
                border: Border.all(color: AppColors.primaryDark, width: 1.5),
              ),
              clipBehavior: Clip.antiAlias,
              child: foto.isEmpty
                  ? Center(
                      child: Text(
                        inisial,
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 40,
                          height: 1,
                          color: AppColors.background,
                        ),
                      ),
                    )
                  : AppImageView(imagePath: foto, fit: BoxFit.cover),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 1.2),
                ),
                child: const Icon(
                  Icons.photo_camera_outlined,
                  size: 15,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // section angka aktivitas
  // Satu bingkai luar dengan garis pemisah di antara sel.
  Widget _buildStatistik() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderPrimary),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _buildKotakStat('$_jumlahTersimpan', 'Tersimpan')),
            Expanded(child: _buildKotakStat('$_jumlahDibuka', 'Dibuka')),
            Expanded(
              child: _buildKotakStat(
                '$_jumlahProvinsi',
                'Provinsi',
                terakhir: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKotakStat(String nilai, String label, {bool terakhir = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        border: terakhir
            ? null
            : const Border(right: BorderSide(color: AppColors.borderPrimary)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            nilai,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 26,
              height: 1,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.9,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // section pintasan
  Widget _buildMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AKTIVITAS',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        _buildBarisMenu(
          nomor: '01',
          nama: 'Koleksi Tersimpan',
          keterangan: 'Arsip yang kamu tandai untuk dibaca lagi',
          onTap: () async {
            await context.push(const BookmarkPage());
            if (!mounted) return;
            await _muatData();
          },
        ),
        _buildBarisMenu(
          nomor: '02',
          nama: 'Ganti Foto Profil',
          keterangan: 'Ambil gambar dari galeri perangkat',
          onTap: _bukaPilihanFoto,
        ),
      ],
    );
  }

  Widget _buildBarisMenu({
    required String nomor,
    required String nama,
    required String keterangan,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 26,
              child: Text(
                nomor,
                style: AppTypography.tag(color: AppColors.primaryDark),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nama, style: AppTypography.labelBold(fontSize: 14)),
                  const SizedBox(height: 1),
                  Text(
                    keterangan,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTombolLogout() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _logout,
        icon: const Icon(
          Icons.logout_rounded,
          size: 18,
          color: AppColors.primary,
        ),
        label: Text(
          'LOGOUT SEKARANG',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
