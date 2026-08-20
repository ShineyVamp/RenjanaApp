import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/navigation.dart';
import '../../services/preference_handler.dart';
import '../auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
          label: const Text(
            "LOGOUT SEKARANG",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            await PreferenceHandler.logOut();
            if (!context.mounted) return;
            messenger.clearSnackBars();
            context.pushAndRemoveAll(const LoginPage());
            messenger.showSnackBar(
              const SnackBar(
                content: Text("Berhasil Logout"),
                duration: Duration(milliseconds: 1200),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.success,
              ),
            );
          },
        ),
      ),
    );
  }
}
