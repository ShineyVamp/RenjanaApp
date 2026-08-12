import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:renjana/extensions/navigation.dart';
import 'package:renjana/views/onboarding.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    goToLogin();
  }

  void goToLogin() async {
    await Future.delayed(Duration(seconds: 5));
    if (!mounted) return null;
    context.pushAndRemoveAll(Onboarding());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F0E7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/Rlogos.png", width: 150),
            Text("RENJANA", style: GoogleFonts.dmSerifDisplay(fontSize: 38)),
            Text(
              "Museum Indonesia Dalam Genggaman",
              style: GoogleFonts.plusJakartaSans(fontSize: 18),
            ),
            SizedBox(
              height: 50,
              width: 300,
              child: LottieBuilder.asset(
                'assets/animations/loading.json',
                fit: BoxFit.cover,
                frameRate: FrameRate(90),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
