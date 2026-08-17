import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:renjana/views/home.dart';

class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  int _selectedPage = 0;

  final List<String> _labels = ["Beranda", "Eksplor", "Peta", "Kuis", "Profil"];

  final List<IconData> _activeIcons = [
    Icons.home,
    Icons.explore_sharp,
    Icons.map,
    Icons.quiz,
    Icons.person,
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
          color: Color(0xffC9362B),
          border: Border(top: BorderSide(color: Colors.black12, width: 0.8)),
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
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        height: 4,
                        width: isSelected ? 32 : 0,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(3),
                          ),
                        ),
                      ),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: Icon(
                          isSelected
                              ? _activeIcons[index]
                              : _nonActIcons[index],
                          key: ValueKey<bool>(isSelected),
                          size: 26,
                          color: isSelected ? Colors.white : Colors.white60,
                        ),
                      ),
                      Text(
                        _labels[index],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.white60,
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
