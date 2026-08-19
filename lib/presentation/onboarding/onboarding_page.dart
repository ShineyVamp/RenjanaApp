import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/extensions/navigation.dart';
import '../../core/widgets/app_button.dart';
import '../auth/login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _items = const [
    {
      'stepNumber': '01/03',
      'title': 'Indonesia,\ndilihat lebih dekat.',
      'description':
          'Temukan keajaiban wastra, arsitektur, dan kearifan lokal dalam kurasi digital yang mendalam.',
      'imagePath': 'assets/images/onboardin1.jpg',
    },
    {
      'stepNumber': '02/03',
      'title': 'Setiap Tempat\nmenyimpan kisah.',
      'description':
          'Telusuri Sejarah, Budaya, dan berbagi sumber terpercaya. Uji pengetahuanmu melalui kuis interaktif.',
      'imagePath': 'assets/images/onboardin2.jpg',
    },
    {
      'stepNumber': '03/03',
      'title': 'Kisah dari\ndaerahmu juga berarti.',
      'description':
          'Telusuri Sejarah, Budaya, dan berbagai sumber terpercaya. Uji pengetahuanmu melalui kuis interaktif.',
      'imagePath': 'assets/images/onboardin3.jpg',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _previous() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _next() {
    if (_currentPage < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.pushReplacement(const LoginPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            physics: const ClampingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return _buildOnboardingSlide(item);
            },
          ),
          // Bottom Navigation Controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    if (_currentPage > 0) ...[
                      Expanded(
                        child: AppButton.outlined(
                          text: 'Kembali',
                          textColor: AppColors.textPrimary,
                          onPressed: _previous,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: AppButton(
                        text: _currentPage == _items.length - 1
                            ? 'Mulai'
                            : 'Lanjut',
                        onPressed: _next,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _items.length,
                    (index) => _buildIndicator(isActive: index == _currentPage),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingSlide(Map<String, dynamic> item) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(item['imagePath'], fit: BoxFit.cover),
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0x80F4F0E7),
                  AppColors.background,
                ],
                stops: [0.3, 0.6, 0.85],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Container(width: 48, height: 2, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Text(
                      item['stepNumber'],
                      style: AppTypography.labelBold(
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(item['title'], style: AppTypography.headingLarge()),
                const SizedBox(height: 12),
                Text(
                  item['description'],
                  style: AppTypography.bodyLarge(),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 140),
              ],
            ),
          ),
        ),
      ],
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
        color: isActive ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
