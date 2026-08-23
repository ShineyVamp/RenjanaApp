import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../extensions/navigation.dart';

// AppBar seragam untuk halaman yang dibuka di atas halaman lain: panah kembali
// di kiri, judul di tengah, dan garis merah tipis di bawahnya.
class AppBarHalaman extends StatelessWidget implements PreferredSizeWidget {
  final String judul;
  final List<Widget>? aksi;

  // Diisi bila AppBar perlu membawa tab atau penyaring di bawah judul.
  final PreferredSizeWidget? bawah;

  // Dilewatkan bila halaman perlu memutuskan sendiri cara menutup dirinya.
  final VoidCallback? onKembali;

  const AppBarHalaman({
    super.key,
    required this.judul,
    this.aksi,
    this.bawah,
    this.onKembali,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bawah?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      surfaceTintColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.primary,
          size: 20,
        ),
        onPressed: onKembali ?? () => context.pop(),
      ),
      title: Text(
        judul,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.headingSmall().copyWith(fontSize: 18),
      ),
      actions: aksi,
      bottom: bawah,
      shape: bawah != null
          ? null
          : const Border(
              bottom: BorderSide(color: AppColors.primary, width: 0.8),
            ),
    );
  }
}
