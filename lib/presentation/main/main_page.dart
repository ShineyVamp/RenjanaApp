import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:renjana/presentation/profile/profile_page.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/user_model.dart';
import '../../services/preference_handler.dart';
import '../admin/widgets/admin_drawer.dart';
import '../home/home_page.dart';
import '../jelajah/jelajah_page.dart';
import '../peta/peta_page.dart';
import '../quiz/quiz_page.dart';

class MainPage extends StatefulWidget {
  final UserSQLModel? currentUser;
  final bool? isAdmin;

  const MainPage({super.key, this.currentUser, this.isAdmin});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  bool get _isAdmin {
    final user = widget.currentUser ?? PreferenceHandler.user;
    if (user != null) return user.isAdminAccount;
    return widget.isAdmin ?? PreferenceHandler.isAdmin;
  }

  String get _userName {
    if (widget.currentUser?.nama.isNotEmpty == true) {
      return widget.currentUser!.nama;
    }
    final savedUser = PreferenceHandler.user;
    if (savedUser?.nama.isNotEmpty == true) {
      return savedUser!.nama;
    }
    return _isAdmin ? 'admin1' : PreferenceHandler.userName;
  }

  final List<String> _labels = ['Beranda', 'Jelajah', 'Peta', 'Kuis', 'Profil'];

  final List<String> _activeIcons = [
    'assets/animations/home.json',
    'assets/animations/compass.json',
    'assets/animations/map.json',
    'assets/animations/quiz.json',
    'assets/animations/person.json',
  ];

  final List<IconData> _inactiveIcons = [
    Icons.home_outlined,
    Icons.explore_outlined,
    Icons.map_outlined,
    Icons.quiz_outlined,
    Icons.person_outline,
  ];

  List<Widget> _getPages() {
    return [
      HomePage(
        userName: _userName,
        isAdmin: _isAdmin,
        onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      JelajahPage(onBukaPeta: () => setState(() => _selectedIndex = 2)),
      const PetaPage(),
      const QuizPage(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final pages = _getPages();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: _isAdmin ? AdminDrawer(currentUser: widget.currentUser) : null,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.primary, width: 0.8)),
        ),
        child: SafeArea(
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: List.generate(pages.length, (index) {
                    final isSelected = _selectedIndex == index;
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
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
                                color: AppColors.primary,
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
                                        frameRate: const FrameRate(120),
                                        repeat: false,
                                        fit: BoxFit.contain,
                                      )
                                    : Icon(
                                        _inactiveIcons[index],
                                        size: 24,
                                        color: AppColors.textMuted,
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
                                    ? AppColors.primary
                                    : AppColors.textMuted,
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
