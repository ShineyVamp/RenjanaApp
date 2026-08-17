import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Onboarding3 extends StatefulWidget {
  const Onboarding3({super.key});

  @override
  State<Onboarding3> createState() => _Onboarding3State();
}

class _Onboarding3State extends State<Onboarding3> {
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/onboardin3.jpg', fit: BoxFit.fitHeight),
            Positioned(
              top: 700,
              child: Container(
                height: 200,
                width: 400,
                foregroundDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, -6),
                      color: Color(0xffF4F0E7),
                      blurStyle: BlurStyle.normal,
                      blurRadius: 100,
                      spreadRadius: 300,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 500),
                  Row(
                    children: [
                      SizedBox(
                        width: 50,
                        child: Divider(thickness: 2, color: Color(0xffC9362B)),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "03/03",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          color: Color(0xffC9362B),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Kisah dari \ndaerahmu juga berarti.",
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // SizedBox(height: 10),
                  Text(
                    "Telusuri Sejarah, Budaya, dan berbagi sumber terpercaya. Uji pengetahuanmu melalui kuis interaktif",
                    style: GoogleFonts.plusJakartaSans(fontSize: 18),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
