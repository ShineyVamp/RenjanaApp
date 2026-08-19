import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizCardWidget extends StatelessWidget {
  final String title;
  final String buttonText;
  final VoidCallback? onStartQuiz;

  const QuizCardWidget({
    super.key,
    this.title = 'Uji Pemahaman',
    this.buttonText = 'MULAI KUIS',
    this.onStartQuiz,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 36),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 32,
          horizontal: 20,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFA9312E),
            width: 1.4,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.quiz_outlined,
              color: Color(0xFFA9312E),
              size: 30,
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1C1815),
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onStartQuiz ?? () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA9312E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
