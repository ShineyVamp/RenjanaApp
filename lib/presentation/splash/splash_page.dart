import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:renjana/presentation/main/main_page.dart';
import 'package:renjana/services/preference_handler.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/extensions/navigation.dart';
import '../onboarding/onboarding_page.dart';

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

  Future<void> _checkLoginAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    if (PreferenceHandler.isLogin) {
      final user = PreferenceHandler.user;
      final isAdmin = PreferenceHandler.isAdmin;
      context.pushAndRemoveAll(MainPage(
        currentUser: user,
        isAdmin: isAdmin,
      ));
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
            Text(
              'Museum Indonesia Dalam Genggaman',
              style: AppTypography.bodyLarge(),
            ),
            const SizedBox(height: 24),
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
