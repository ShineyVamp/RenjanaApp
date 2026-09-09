import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/navigation.dart';
import '../../../auth/data/models/user_model.dart';
import '../manage_content_page.dart';
import '../manage_kategori_page.dart';
import '../manage_laporan_page.dart';
import '../manage_lencana_page.dart';
import '../manage_usulan_page.dart';
import '../manage_quiz_page.dart';

class AdminDrawer extends StatelessWidget {
  final UserSQLModel? currentUser;

  const AdminDrawer({super.key, this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // header drawer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 90, 20, 20),
              child: Text(
                "BUAT ATMIN",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            // menu kelola kuis
            _buildDrawerTile(
              context: context,
              icon: Icons.quiz_rounded,
              title: 'Manage Quiz',
              onTap: () {
                Navigator.pop(context);
                context.push(const AdminManageQuizPage());
              },
            ),

            // menu kelola konten
            _buildDrawerTile(
              context: context,
              icon: Icons.dashboard_customize_rounded,
              title: 'Manage Konten Utama',
              onTap: () {
                Navigator.pop(context); // tutup drawer
                context.push(const AdminManageContentPage());
              },
            ),

            // menu usulan dari pengguna
            _buildDrawerTile(
              context: context,
              icon: Icons.volunteer_activism_rounded,
              title: 'Usulan Konten',
              onTap: () {
                Navigator.pop(context);
                context.push(const AdminManageUsulanPage());
              },
            ),

            // menu logo lencana
            _buildDrawerTile(
              context: context,
              icon: Icons.military_tech_rounded,
              title: 'Logo Lencana',
              onTap: () {
                Navigator.pop(context);
                context.push(const AdminManageLencanaPage());
              },
            ),

            // menu kelola kategori
            _buildDrawerTile(
              context: context,
              icon: Icons.category_rounded,
              title: 'Kelola Kategori',
              onTap: () {
                Navigator.pop(context);
                context.push(const AdminManageKategoriPage());
              },
            ),

            // menu moderasi laporan
            _buildDrawerTile(
              context: context,
              icon: Icons.report_problem_rounded,
              title: 'Moderasi Laporan',
              onTap: () {
                Navigator.pop(context);
                context.push(const AdminManageLaporanPage());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          title: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
