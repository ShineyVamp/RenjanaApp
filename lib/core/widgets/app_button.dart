import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

enum AppButtonType { primary, outlined }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final double borderRadius;
  final Color? textColor;

  static const double _height = 52;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.borderRadius = 12,
    this.textColor,
  });

  const AppButton.outlined({
    super.key,
    required this.text,
    required this.onPressed,
    this.borderRadius = 12,
    this.textColor,
  }) : type = AppButtonType.outlined;

  @override
  Widget build(BuildContext context) {
    final isPrimary = type == AppButtonType.primary;
    final effectiveTextColor =
        textColor ?? (isPrimary ? Colors.white : AppColors.primary);

    final label = Text(
      text,
      style: AppTypography.buttonText(color: effectiveTextColor),
      textAlign: TextAlign.center,
    );

    if (type == AppButtonType.outlined) {
      return SizedBox(
        width: double.infinity,
        height: _height,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.transparent,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            elevation: 0,
          ),
          child: label,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: _height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: label,
      ),
    );
  }
}
