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
  final bool _isnavigating = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _previous() async {
    // if (_isnavigating) return;

    if (_currentPage < _pages.length) {
      // setState(() {
      //   _isnavigating = true;
      // });
      await _pageController.previousPage(
        duration: Duration(milliseconds: 550),
        curve: Curves.easeInOut,
      );
    }
  }

  void _next() async {
    // if (_isnavigating) return;

    if (_currentPage < _pages.length - 1) {
      // setState(() {
      //   _isnavigating = true;
      // });
      await _pageController.nextPage(
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
          //     left: 20,
          //     child: Stack(
          //       alignment: AlignmentGeometry.center,
          //       children: [
          //         Container(
          //           width: 45,
          //           height: 45,
          //           decoration: BoxDecoration(
          //             boxShadow: [
          //               BoxShadow(
          //                 color: Colors.black,
          //                 blurRadius: 1,
          //                 spreadRadius: 0.4,
          //               ),
          //             ],
          //             shape: BoxShape.circle,
          //             color: Color(0xffC9362B).withValues(alpha: 1),
          //           ),
          //         ),
          //         IconButton(
          //           onPressed: () {},
          //           icon: Icon(
          //             Icons.arrow_back_outlined,
          //             size: 30,
          //             color: Colors.white,
          //           ),
          //         ),
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
