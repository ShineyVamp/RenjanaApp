import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppImageView extends StatelessWidget {
  final String? imagePath;
  final String? sumberFoto;
  final BoxFit fit;
  final double? width;
  final double? height;
  final int? cacheWidth;
  final int? cacheHeight;
  final BorderRadius? borderRadius;

  const AppImageView({
    super.key,
    required this.imagePath,
    this.sumberFoto,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.cacheWidth,
    this.cacheHeight,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (imagePath == null || imagePath!.trim().isEmpty) {
      imageWidget = _defaultPlaceholder();
    } else {
      final path = imagePath!.trim();
      int? targetCacheWidth = cacheWidth;
      int? targetCacheHeight = cacheHeight;

      if (targetCacheWidth == null && width != null && width! > 0) {
        targetCacheWidth = (width! * 2.5).round();
      }
      if (targetCacheHeight == null && height != null && height! > 0) {
        targetCacheHeight = (height! * 2.5).round();
      }
      if (targetCacheWidth == null && targetCacheHeight == null) {
        targetCacheWidth = 1080;
      }

      if (path.startsWith('http://') || path.startsWith('https://')) {
        imageWidget = CachedNetworkImage(
          imageUrl: path,
          fit: fit,
          width: width,
          height: height,
          memCacheWidth: targetCacheWidth,
          memCacheHeight: targetCacheHeight,
          placeholder: (context, url) => Container(
            width: width,
            height: height,
            color: AppColors.surfaceMuted.withValues(alpha: 0.3),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          ),
          errorWidget: (context, url, error) => _defaultPlaceholder(),
        );
      } else if (path.startsWith('assets/')) {
        imageWidget = Image.asset(
          path,
          fit: fit,
          width: width,
          height: height,
          cacheWidth: targetCacheWidth,
          cacheHeight: targetCacheHeight,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) => _defaultPlaceholder(),
        );
      } else {
        imageWidget = Image.file(
          File(path),
          fit: fit,
          width: width,
          height: height,
          cacheWidth: targetCacheWidth,
          cacheHeight: targetCacheHeight,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) => _defaultPlaceholder(),
        );
      }
    }

    Widget resultWidget = imageWidget;

    if (sumberFoto != null && sumberFoto!.trim().isNotEmpty) {
      resultWidget = Stack(
        alignment: Alignment.bottomRight,
        children: [
          imageWidget,
          Positioned(
            bottom: 8,
            right: 8,
            child: _buildSumberBadge(sumberFoto!.trim()),
          ),
        ],
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: resultWidget);
    }

    return resultWidget;
  }

  // section badge sumber foto
  Widget _buildSumberBadge(String sumber) {
    final double maxW = width != null && width! > 24
        ? (width! - 16).clamp(50.0, 160.0)
        : 160.0;

    return Container(
      constraints: BoxConstraints(maxWidth: maxW),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        sumber,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 9.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // section placeholder bawaan
  Widget _defaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.surfaceMuted,
      child: const Center(
        child: Icon(Icons.image_outlined, color: Colors.black26, size: 28),
      ),
    );
  }
}
