import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/extensions/navigation.dart';
import '../../../core/storage/preference_handler.dart';
import '../../onboarding/presentation/onboarding_page.dart';
import 'package:renjana/features/auth/data/repositories/user_repository.dart';
import 'package:renjana/features/shell/presentation/main_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginAndNavigate();
  }

  // section validasi sesi dan navigasi
  Future<void> _checkLoginAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    if (PreferenceHandler.isLogin) {
      var user = PreferenceHandler.user;
      final uid = PreferenceHandler.userUid;
      if (uid.isNotEmpty) {
        try {
          final fresh = await UserRepository().getUserByUid(uid);
          if (fresh != null) {
            user = fresh;
            await PreferenceHandler.saveUser(fresh);
          }
        } catch (_) {}
      }
      final isAdmin = user?.isAdminAccount ?? PreferenceHandler.isAdmin;
      if (!mounted) return;
      context.pushAndRemoveAll(MainPage(currentUser: user, isAdmin: isAdmin));
    } else {
      context.pushAndRemoveAll(const OnboardingPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/Rlogos.png', width: 140),
            const SizedBox(height: 12),
            Text('RENJANA', style: AppTypography.headingLarge()),
            const SizedBox(height: 6),
            Text('Indonesia Dalam Genggaman', style: AppTypography.bodyLarge()),
            SizedBox(
              height: 50,
              width: 250,
              child: Lottie.asset(
                'assets/animations/loading.json',
                fit: BoxFit.cover,
                frameRate: const FrameRate(90),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
