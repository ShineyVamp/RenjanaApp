import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppImageView extends StatelessWidget {
  final String? imagePath;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? placeholder;

  const AppImageView({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (imagePath == null || imagePath!.trim().isEmpty) {
      imageWidget = placeholder ?? _defaultPlaceholder();
    } else {
      final path = imagePath!.trim();
      if (path.startsWith('assets/')) {
        imageWidget = Image.asset(
          path,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) =>
              placeholder ?? _defaultPlaceholder(),
        );
      } else {
        final file = File(path);
        if (file.existsSync()) {
          imageWidget = Image.file(
            file,
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (context, error, stackTrace) =>
                placeholder ?? _defaultPlaceholder(),
          );
        } else {
          imageWidget = Image.asset(
            'assets/images/1308history.png',
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (context, error, stackTrace) =>
                placeholder ?? _defaultPlaceholder(),
          );
        }
      }
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _defaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.surfaceMuted,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: Colors.black26,
          size: 28,
        ),
      ),
    );
  }
}
