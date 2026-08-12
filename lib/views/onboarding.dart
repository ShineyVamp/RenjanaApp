import 'package:control_style/control_style.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:renjana/extensions/navigation.dart';
import 'package:renjana/views/login_page.dart';
import 'package:renjana/views/oboarding/onboarding1.dart';
import 'package:renjana/views/oboarding/onboarding2.dart';
import 'package:renjana/views/oboarding/onboarding3.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _previous() {
    if (_pageController.hasClients && _pageController.page != null) {
      if (_pageController.page! % 1 != 0) return;
    }

    if (_currentPage < _pages.length) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 550),
        curve: Curves.easeInOut,
      );
    }
  }

  void _next() {
    if (_pageController.hasClients && _pageController.page != null) {
      if (_pageController.page! % 1 != 0) return;
    }

    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 550),
        curve: Curves.easeInOut,
      );
    } else {
      context.pushReplacement(LoginPage());
    }
  }

  final List<Widget> _pages = [Onboarding1(), Onboarding2(), Onboarding3()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F0E7),
      body: Stack(
        children: [
          Container(
            color: Colors.transparent,
            child: Column(
              children: [
                Flexible(
                  child: PageView(
                    physics: NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    controller: _pageController,
                    children: _pages,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 37),
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Row(
                        children: [
                          if (_currentPage > 0)
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  fixedSize: Size(150, 55),
                                  elevation: 0,
                                  animationDuration: Duration(microseconds: 1),
                                  side: BorderSide(
                                    color: Color(0xffC9362B),
                                    width: 2,
                                    style: BorderStyle.solid,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadiusGeometry.circular(
                                      15,
                                    ),
                                  ),
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                onPressed: _previous,
                                child: Text(
                                  "Kembali",
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          if (_currentPage > 0) SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                animationDuration: Duration(microseconds: 1),
                                fixedSize: Size(150, 55),
                                elevation: 1,
                                shape: DecoratedOutlinedBorder(
                                  child: RoundedRectangleBorder(
                                    borderRadius: BorderRadiusGeometry.circular(
                                      15,
                                    ),
                                  ),
                                ),
                                backgroundColor: Color(0xffC9362B),
                                // shadowColor: Colors.black,
                              ),
                              onPressed: _next,
                              child: Text(
                                "Lanjut",
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: .center,
                        children: List.generate(
                          _pages.length,
                          (index) =>
                              _buildIndicator(isActive: index == _currentPage),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // if (_currentPage > 0)
          //   Positioned(
          //     top: 50,
          //     right: 20,
          //     child: Stack(
          //       alignment: AlignmentGeometry.center,
          //       children: [
          //         GestureDetector(
          //           onTap: () {
          //             context.pushAndRemoveAll(LoginPage());
          //           },
          //           child: AnimatedContainer(
          //             duration: Duration(microseconds: 1),
          //             width: 85,
          //             height: 45,
          //             decoration: BoxDecoration(
          //               border: Border.fromBorderSide(BorderSide(color: Color(0xffC9362B).withValues(alpha: 0.5), width: 1.5,strokeAlign: BorderSide.strokeAlignOutside)),
          //               borderRadius: BorderRadius.circular(15),
          //               color: Color(0xffF4F0E7),
          //             ),
                    
          //           ),
          //         ),
          //         Text("Lewati", style: GoogleFonts.plusJakartaSans(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),)
          //       ],
          //     ),
          //   ),
        ],
      ),
    );
  }

  Widget _buildIndicator({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 4,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? Color(0xffC9362B) : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
