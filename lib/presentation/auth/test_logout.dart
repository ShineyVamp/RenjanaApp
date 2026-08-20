import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/navigation.dart';
import '../../services/preference_handler.dart';
import 'login_page.dart';

class Logout18 extends StatefulWidget {
  const Logout18({super.key});

  @override
  State<Logout18> createState() => _Logout18State();
}

class _Logout18State extends State<Logout18> {
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
