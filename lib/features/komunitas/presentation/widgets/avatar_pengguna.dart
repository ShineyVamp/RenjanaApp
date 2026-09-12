import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_image.dart';

// section widget avatar pengguna
class AvatarPengguna extends StatelessWidget {
  final String? fotoUrl;
  final String nama;
  final double radius;
  final VoidCallback? onTap;

  const AvatarPengguna({
    super.key,
    this.fotoUrl,
    required this.nama,
    this.radius = 16,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final adaFoto = fotoUrl != null && fotoUrl!.trim().isNotEmpty;
    final inisial = nama.trim().isNotEmpty ? nama.trim()[0].toUpperCase() : '?';

    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryDark.withValues(alpha: 0.12),
      ),
      clipBehavior: Clip.antiAlias,
      child: adaFoto
          ? AppImageView(
              imagePath: fotoUrl,
              fit: BoxFit.cover,
              width: size,
              height: size,
            )
          : Center(
              child: Text(
                inisial,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: radius * 0.85,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: avatar,
      );
    }

    return avatar;
  }
}
