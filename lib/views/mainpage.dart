import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:renjana/views/appPage/home.dart';
import 'package:renjana/views/test_day_20.dart';

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

  final List<Widget> _pages = const [
    Home(),
    TestDay20(),
    Home(),
    Home(),
    Home(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F0E7),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: _pages[_selectedPage],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xffF4F0E7),
          border: Border(top: BorderSide(color: Color(0xffC9362B), width: 0.8)),
        ),
        child: SafeArea(
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 8),
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                              height: 4,
                              width: isSelected ? 36 : 0,
                              decoration: const BoxDecoration(
                                color: Color(0xffC9362B),
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(3),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              height: 28,
                              width: 28,
                              child: Center(
                                child: isSelected
                                    ? Lottie.asset(
                                        _activeIcons[index],
                                        repeat: false,
                                        fit: BoxFit.contain,
                                      )
                                    : Icon(
                                        _nonActIcons[index],
                                        size: 24,
                                        color: const Color(0x80C9362B),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _labels[index],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? const Color(0xffC9362B)
                                    : const Color(0x80C9362B),
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
          ),
        ),
      ),
    );
  }
}
