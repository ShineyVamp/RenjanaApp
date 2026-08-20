import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

enum AppButtonType { primary, outlined, secondary }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final double? width;
  final double height;
  final double borderRadius;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.width,
    this.height = 52,
    this.borderRadius = 12,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  const AppButton.outlined({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height = 52,
    this.borderRadius = 12,
    this.icon,
    this.backgroundColor,
    this.textColor,
  }) : type = AppButtonType.outlined;

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ??
        (type == AppButtonType.primary
            ? AppColors.primary
            : Colors.transparent);

    final effectiveTextColor = textColor ??
        (type == AppButtonType.primary ? Colors.white : AppColors.primary);

    final textWidget = Text(
      text,
      style: AppTypography.buttonText(color: effectiveTextColor),
      textAlign: TextAlign.center,
    );

    final buttonChild = icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon!,
              const SizedBox(width: 8),
              textWidget,
            ],
          )
        : textWidget;

    if (type == AppButtonType.outlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: effectiveBg,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            elevation: 0,
          ),
          child: buttonChild,
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBg,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: buttonChild,
      ),
    );
  }
}
