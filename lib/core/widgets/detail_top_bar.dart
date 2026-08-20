import 'package:flutter/material.dart';
import '../extensions/navigation.dart';
import '../constants/app_colors.dart';

class DetailTopBar extends StatelessWidget {
  final bool isBookmarked;
  final VoidCallback? onBookmarkToggle;
  final VoidCallback? onShare;
  final VoidCallback? onBack;
  final VoidCallback? onHome;
  final bool showHomeButton;

  const DetailTopBar({
    super.key,
    required this.isBookmarked,
    this.onBookmarkToggle,
    this.onShare,
    this.onBack,
    this.onHome,
    this.showHomeButton = true,
  });

  Widget _buildCircleButton({
    required Widget icon,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: AppColors.primaryDark,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(9), child: icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildCircleButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 18,
                  ),
                  onTap: onBack ?? () => context.pop(),
                ),
                if (showHomeButton) ...[
                  const SizedBox(width: 10),
                  _buildCircleButton(
                    icon: const Icon(
                      Icons.home_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    // Kembali ke MainPage: halaman detail bisa bertumpuk
                    // (detail -> detail lainnya), jadi semua ditutup sekaligus.
                    onTap:
                        onHome ??
                        () => Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst),
                  ),
                ],
              ],
            ),
            Row(
              children: [
                _buildCircleButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: Colors.white,
                    size: 18,
                  ),
                  onTap: onBookmarkToggle,
                ),
                const SizedBox(width: 10),
                _buildCircleButton(
                  icon: const Icon(
                    Icons.share_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  onTap: onShare ?? () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
