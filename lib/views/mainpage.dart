import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:renjana/views/home.dart';

class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  int _selectedPage = 0;

  final List<String> _labels = ["Beranda", "Eksplor", "Peta", "Kuis", "Profil"];

  final List<String> _activeIcons = [
    'assets/animations/home.json',
    'assets/animations/compass.json',
    'assets/animations/map.json',
    'assets/animations/quiz.json',
    'assets/animations/person.json',
  ];

  final List<IconData> _nonActIcons = [
    Icons.home_outlined,
    Icons.explore_outlined,
    Icons.map_outlined,
    Icons.quiz_outlined,
    Icons.person_outline,
  ];

  final List<Widget> _pages = const [Home(), Home(), Home(), Home(), Home()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedPage],
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Color(0xffF4F0E7),
          border: Border(top: BorderSide(color: Color(0xffC9362B), width: 0.8)),
        ),
        child: SafeArea(
          child: Row(
            children: List.generate(_pages.length, (index) {
              final isSelected = _selectedPage == index;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _selectedPage = index;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Transform.translate(
                        offset: Offset(0, -1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          height: 5,
                          width: isSelected ? 40 : 0,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color(0xffC9362B)
                                : Colors.transparent,
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      isSelected
                          ? Lottie.asset(
                              _activeIcons[index],
                              height: 26,
                              repeat: false,
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                            )
                          : Icon(
                              _nonActIcons[index],
                              size: 26,
                              color: isSelected
                                  ? Color(0xffC9362B)
                                  : Color(0x80C9362B),
                            ),
                      Text(
                        _labels[index],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected
                              ? Color(0xffC9362B)
                              : Color(0x80C9362B),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
