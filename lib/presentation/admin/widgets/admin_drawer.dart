import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/extensions/navigation.dart';
import '../../../data/models/user_model.dart';
import '../../auth/login_page.dart';
import '../manage_content_page.dart';
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
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Text(
                "BUAT ATMIN",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            // Menu 1: Manage Quiz
            _buildDrawerTile(
              context: context,
              icon: Icons.quiz_rounded,
              title: 'Manage Quiz',
              onTap: () {
                Navigator.pop(context);
                context.push(const AdminManageQuizPage());
              },
            ),

            // Menu 2: Manage Konten Utama
            _buildDrawerTile(
              context: context,
              icon: Icons.dashboard_customize_rounded,
              title: 'Manage Konten Utama',
              onTap: () {
                Navigator.pop(context); // close drawer
                context.push(const AdminManageContentPage());
              },
            ),

            // const Spacer(),
            // const Divider(color: AppColors.borderPrimary, height: 1),

            // Logout Option
            // ListTile(
            //   leading: Container(
            //     padding: const EdgeInsets.all(8),
            //     decoration: BoxDecoration(
            //       color: AppColors.primary.withOpacity(0.1),
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //     child: const Icon(
            //       Icons.logout_rounded,
            //       color: AppColors.primary,
            //       size: 20,
            //     ),
            //   ),
            //   title: Text(
            //     'Keluar Akun',
            //     style: GoogleFonts.plusJakartaSans(
            //       fontSize: 14,
            //       fontWeight: FontWeight.bold,
            //       color: AppColors.primary,
            //     ),
            //   ),
            //   subtitle: Text(
            //     'Kembali ke halaman login',
            //     style: GoogleFonts.plusJakartaSans(
            //       fontSize: 11,
            //       color: AppColors.textSecondary,
            //     ),
            //   ),
            //   onTap: () {
            //     Navigator.pop(context);
            //     context.pushAndRemoveAll(const LoginPage());
            //   },
            // ),
            // const SizedBox(height: 12),
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
