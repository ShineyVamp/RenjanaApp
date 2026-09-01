import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dekorasi.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/lencana_katalog.dart';
import '../../core/extensions/navigation.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/header_halaman.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/arsip_dibaca_repository.dart';
import '../../data/models/usulan_model.dart';
import '../../data/repositories/hasil_kuis_repository.dart';
import '../../data/repositories/jelajah_repository.dart';
import '../../data/repositories/lencana_repository.dart';
import '../../data/repositories/runtun_repository.dart';
import '../../data/repositories/usulan_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../services/preference_handler.dart';
import '../auth/login_page.dart';
import '../capaian/jejak_saya_page.dart';
import '../capaian/riwayat_kuis_page.dart';
import '../kontribusi/kontribusi_page.dart';
import 'edit_profil_page.dart';
import 'widgets/panel_lencana.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserRepository _userRepository = UserRepository();
  final JelajahRepository _jelajahRepository = JelajahRepository();
  final ArsipDibacaRepository _arsipDibacaRepository = ArsipDibacaRepository();
  final RuntunRepository _runtunRepository = RuntunRepository();
  final HasilKuisRepository _hasilKuisRepository = HasilKuisRepository();
  final UsulanRepository _usulanRepository = UsulanRepository();
  final LencanaRepository _lencanaRepository = LencanaRepository();

  UserSQLModel? _user;
  int _jumlahDibuka = 0;
  int _jumlahProvinsi = 0;
  String _gelar = 'Pelajar';
  RingkasanRuntun _runtun = const RingkasanRuntun();
  RingkasanKuis _ringkasanKuis = const RingkasanKuis();
  int _usulanTotal = 0;
  int _usulanTerbuka = 0;
  int _usulanDisetujui = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    final sesi = PreferenceHandler.user;

    // data terbaru dibaca dari database lewat id, bukan dari salinan sesi
    final user =
        await _userRepository.getUserById(PreferenceHandler.userId) ?? sesi;

    final refs = await _arsipDibacaRepository.semua();
    final dibaca = await _jelajahRepository.ambilDariRiwayat(refs);
    final provinsi = dibaca
        .map((item) => item.asalProvinsi?.trim().toLowerCase())
        .whereType<String>()
        .where((nama) => nama.isNotEmpty)
        .toSet();

    final runtun = await _runtunRepository.ringkasan();
    final kuis = await _hasilKuisRepository.ringkasan();
    final usulanTotal = await _usulanRepository.jumlahMilikSaya();
    final usulanMenunggu = await _usulanRepository.jumlahMilikSaya(
      status: StatusUsulan.menunggu,
    );
    final usulanRevisi = await _usulanRepository.jumlahMilikSaya(
      status: StatusUsulan.revisi,
    );
    final usulanDisetujui = await _usulanRepository.jumlahDisetujui();

    final statusLencana = await _lencanaRepository.evaluasi();
    final terbuka = statusLencana.where((s) => s.terbuka).length;
    final gelar = gelarDariLencana(terbuka);

    if (!mounted) return;
    setState(() {
      _user = user;
      _jumlahDibuka = refs.length;
      _jumlahProvinsi = provinsi.length;
      _gelar = gelar.nama;
      _runtun = runtun;
      _ringkasanKuis = kuis;
      _usulanTotal = usulanTotal;
      _usulanTerbuka = usulanMenunggu + usulanRevisi;
      _usulanDisetujui = usulanDisetujui;
      _isLoading = false;
    });
  }

  Future<void> _bukaEditProfil() async {
    final user = _user;
    if (user == null) return;

    await context.push(EditProfilPage(user: user));
    if (!mounted) return;
    await _muatData();
  }

  Future<void> _bukaJejak(int tab) async {
    await context.push(JejakSayaPage(tabAwal: tab));
    if (!mounted) return;
    await _muatData();
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
            : Column(
                children: [
                  // header tetap, sejajar dengan Jelajah, Peta, dan Kuis
                  const HeaderHalaman(judul: 'Profil', garisBawah: false),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: _muatData,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                            children: [
                              _buildIdentitas(user),
                              const SizedBox(height: 22),
                              _buildStatistik(),
                              const SizedBox(height: 18),
                              PanelLencana(onBerubah: _muatData),
                              const SizedBox(height: 14),
                              _buildPanelRekorKuis(),
                              const SizedBox(height: 14),
                              _buildPanelKontribusi(),
                              const SizedBox(height: 26),
                              _buildTombolLogout(),
                              const SizedBox(height: 18),
                              Text(
                                'RENJANA v1.0.0 · ARSIP BUDAYA NUSANTARA',
                                textAlign: TextAlign.center,
                                style: AppTypography.caption(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

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
                  isAdmin ? 'PENGELOLA ARSIP' : _gelar.toUpperCase(),
                  style: AppTypography.eyebrow(fontSize: 10.5),
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
        IconButton(
          onPressed: _bukaEditProfil,
          icon: const Icon(Icons.edit_outlined, size: 20),
          color: AppColors.primary,
          tooltip: 'Edit profil',
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  // Foto profil, atau kotak berisi huruf depan nama bila foto belum ada.
  Widget _buildAvatar(UserSQLModel? user, String nama) {
    final foto = (user?.fotoProfil ?? '').trim();
    final inisial = nama.trim().isEmpty ? '?' : nama.trim()[0].toUpperCase();

    return GestureDetector(
      onTap: _bukaEditProfil,
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
                  Icons.edit_outlined,
                  size: 14,
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
        borderRadius: AppDekorasi.radiusKartu,
        border: Border.all(color: AppColors.borderPrimary),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _buildKotakStat(
                '${_runtun.berjalan}',
                'Runtun',
                sorot: _runtun.berjalan > 0,
              ),
            ),

            Expanded(flex: 2, child: _buildKotakJejak()),
          ],
        ),
      ),
    );
  }

  Widget _buildKotakStat(
    String nilai,
    String label, {
    bool terakhir = false,
    bool sorot = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
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
                fontSize: 24,
                height: 1,
                color: sorot ? AppColors.gold : AppColors.primary,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    label.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: AppTypography.eyebrow(
                      fontSize: 9,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.9,
                    ),
                  ),
                ),
                if (onTap != null)
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 12,
                    color: AppColors.primary,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Arsip dan provinsi digabung dalam satu kotak karena keduanya menuju
  // halaman yang sama. Bentuk tiap angkanya mengikuti kotak Runtun.
  Widget _buildKotakJejak() {
    return GestureDetector(
      onTap: () => _bukaJejak(0),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 14, 4, 14),
        child: Row(
          children: [
            Expanded(child: _buildAngkaJejak('$_jumlahDibuka', 'Arsip')),
            Expanded(child: _buildAngkaJejak('$_jumlahProvinsi', 'Provinsi')),
            const Padding(
              padding: EdgeInsets.only(right: 6),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAngkaJejak(String nilai, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(nilai, style: AppTypography.angka()),
        const SizedBox(height: 5),
        Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: AppTypography.eyebrow(
            fontSize: 9,
            color: AppColors.textSecondary,
            letterSpacing: 0.9,
          ),
        ),
      ],
    );
  }

  // section rekor kuis, ringkas dalam satu kotak
  Widget _buildPanelRekorKuis() {
    final ringkas = _ringkasanKuis;
    final adaData = ringkas.percobaan > 0;

    return GestureDetector(
      onTap: () async {
        await context.push(const RiwayatKuisPage());
        if (!mounted) return;
        await _muatData();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
        decoration: AppDekorasi.panel(),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('REKOR KUIS', style: AppTypography.eyebrow()),
                  const SizedBox(height: 2),
                  Text(
                    adaData ? 'Ketepatan ${ringkas.persen}%' : 'Belum ada kuis',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 24,
                      color: AppColors.textPrimary,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    adaData
                        ? '${ringkas.totalBenar} benar dari '
                              '${ringkas.totalSoal} soal · '
                              '${ringkas.percobaan} percobaan'
                        : 'Kerjakan satu kuis untuk mulai mencatat rekor',
                    style: AppTypography.bodySmall().copyWith(
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                  if (ringkas.temaSempurna > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${ringkas.temaSempurna} tema sempurna',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  // section kontribusi, memakai bentuk yang sama dengan panel rekor kuis
  Widget _buildPanelKontribusi() {
    final adaTindakan = _usulanTerbuka > 0;

    return GestureDetector(
      onTap: () async {
        await context.push(const KontribusiPage());
        if (!mounted) return;
        await _muatData();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
        decoration: adaTindakan
            ? AppDekorasi.panelCapaian(AppColors.warning)
            : AppDekorasi.panel(),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('KONTRIBUSI', style: AppTypography.eyebrow()),
                  const SizedBox(height: 2),
                  Text(
                    _usulanTotal == 0
                        ? 'Belum ada usulan'
                        : '$_usulanDisetujui arsip terbit',
                    style: AppTypography.angka(
                      color: AppColors.textPrimary,
                    ).copyWith(height: 1.1),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _usulanTotal == 0
                        ? 'Usulkan arsip daerah Anda untuk ikut melestarikan'
                        : '$_usulanTotal usulan diajukan',
                    style: AppTypography.caption(fontSize: 11, height: 1.35),
                  ),
                  if (adaTindakan) ...[
                    const SizedBox(height: 4),
                    Text(
                      '$_usulanTerbuka masih dalam proses',
                      style: AppTypography.caption(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
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
