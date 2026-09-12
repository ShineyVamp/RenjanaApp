import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dekorasi.dart';
import '../../../core/extensions/navigation.dart';
import '../../auth/data/models/user_model.dart';
import '../../auth/data/repositories/user_repository.dart';
import '../data/models/komunitas_model.dart';
import '../data/repositories/komunitas_repository.dart';
import 'detail_diskusi_page.dart';
import 'widgets/avatar_pengguna.dart';
import 'widgets/badge_penulis.dart';

// section halaman profil pengguna lain
class ProfilPenggunaLainPage extends StatefulWidget {
  final int userId;
  final String? username;
  final String nama;
  final String? fotoProfil;
  final String role;
  final String gelar;
  final List<String> badgePilihan;

  const ProfilPenggunaLainPage({
    super.key,
    required this.userId,
    this.username,
    required this.nama,
    this.fotoProfil,
    this.role = 'user',
    this.gelar = 'Pengelana Budaya',
    this.badgePilihan = const [],
  });

  @override
  State<ProfilPenggunaLainPage> createState() => _ProfilPenggunaLainPageState();
}

class _ProfilPenggunaLainPageState extends State<ProfilPenggunaLainPage> {
  final UserRepository _userRepo = UserRepository();
  final KomunitasRepository _komunitasRepo = KomunitasRepository();

  UserSQLModel? _userDetail;
  List<DiskusiModel> _daftarDiskusi = [];
  bool _isLoadingDiskusi = true;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  // section muat data profil dan diskusi
  Future<void> _muatData() async {
    setState(() {
      _isLoadingDiskusi = true;
    });

    UserSQLModel? user;
    if (widget.userId > 0) {
      user = await _userRepo.getUserById(widget.userId);
    }
    if (user == null && widget.username != null && widget.username!.isNotEmpty) {
      user = await _userRepo.getUserByUsername(widget.username!);
    }

    final diskusi = await _komunitasRepo.getDiskusiByUserId(
      widget.userId,
      username: widget.username,
      limit: 8,
    );

    if (!mounted) return;
    setState(() {
      _userDetail = user;
      _daftarDiskusi = diskusi;
      _isLoadingDiskusi = false;
    });
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
    final effectiveNama = (_userDetail?.nama.isNotEmpty ?? false)
        ? _userDetail!.nama
        : widget.nama;
    final effectiveUsername = (_userDetail?.username.isNotEmpty ?? false)
        ? _userDetail!.username
        : (widget.username ?? '');
    final effectiveFoto = (_userDetail?.fotoProfil?.isNotEmpty ?? false)
        ? _userDetail!.fotoProfil
        : widget.fotoProfil;
    final effectiveRole = (_userDetail?.role.isNotEmpty ?? false)
        ? _userDetail!.role
        : widget.role;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(10, 8, 20, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Profil Penjelajah',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 24,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _muatData,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    // section kartu identitas
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: AppDekorasi.panel(),
                      child: Column(
                        children: [
                          AvatarPengguna(
                            fotoUrl: effectiveFoto,
                            nama: effectiveNama,
                            radius: 38,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            effectiveNama,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 22,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                          if (effectiveUsername.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              '@$effectiveUsername',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          BadgePenulis(
                            role: effectiveRole,
                            gelar: widget.gelar,
                            badgePilihan: widget.badgePilihan,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // section header daftar diskusi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Diskusi Terakhir',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 18,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Maks. 8 diskusi',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // section list diskusi pengguna
                    if (_isLoadingDiskusi)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 36),
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2.5,
                          ),
                        ),
                      )
                    else if (_daftarDiskusi.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 32,
                        ),
                        decoration: AppDekorasi.panel(),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 36,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Belum ada diskusi publik',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ..._daftarDiskusi.map((diskusi) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: InkWell(
                            onTap: () {
                              if (diskusi.id != null) {
                                context.push(
                                  DetailDiskusiPage(
                                    diskusiId: diskusi.id!,
                                    initialDiskusi: diskusi,
                                  ),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: AppDekorasi.panel(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          diskusi.kategori,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryDark,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        _formatWaktu(diskusi.dibuatPada),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10.5,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    diskusi.judul,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.thumb_up_alt_outlined,
                                        size: 13,
                                        color: AppColors.textMuted,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${diskusi.jumlahSuara}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        size: 13,
                                        color: AppColors.textMuted,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${diskusi.jumlahJawaban}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
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
