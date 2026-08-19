import 'package:flutter/material.dart';
import '../extensions/navigation.dart';

class DetailTopBar extends StatelessWidget {
  final bool isBookmarked;
  final VoidCallback? onBookmarkToggle;
  final VoidCallback? onShare;
  final VoidCallback? onBack;

  const DetailTopBar({
    super.key,
    required this.isBookmarked,
    this.onBookmarkToggle,
    this.onShare,
    this.onBack,
  });

  Widget _buildCircleButton({
    required Widget icon,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: const Color(0xFFA9312E),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: icon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCircleButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 18,
              ),
              onTap: onBack ?? () => context.pop(),
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
