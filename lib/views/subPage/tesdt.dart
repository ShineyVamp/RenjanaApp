import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CobaJir extends StatefulWidget {
  const CobaJir({super.key});

  @override
  State<CobaJir> createState() => _CobaJirState();
}

class _CobaJirState extends State<CobaJir> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // garis
              // if (!isLast)
              Positioned(
                top: 8,
                bottom: 0,
                left: 3,
                child: Container(width: 1.5, color: const Color(0xFFD8CFBF)),
              ),

              // penanda
              Positioned(
                top: 4,
                left: 0,
                bottom: 0,
                child: Container(
                  width: 7.5,
                  height: 7.5,
                  color: const Color(0xFFA9312E),
                ),
              ),

              // komponen
              Padding(
                padding: const EdgeInsets.only(left: 22, bottom: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "anjay",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: const Color(0xFFA9312E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "anjay",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1C1815),
                        height: 1.18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "anjay",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        height: 1.55,
                        color: const Color(0xFF4A443F),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: AspectRatio(
                        aspectRatio: 16 / 10,
                        child: Container(
                          color: const Color(0xFFCFC8B8),
                          child: const Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 32,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Text("data"),
        ],
      ),
    );
  }
}
