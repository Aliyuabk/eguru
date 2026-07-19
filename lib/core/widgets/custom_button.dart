import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double? height;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.width,
    this.height,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height ?? 50,
      child: _buildButton(),
    );
  }

  Widget _buildButton() {
    switch (type) {
      case ButtonType.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: CustomButtonStyles.primary.copyWith(
            backgroundColor: WidgetStateProperty.all(backgroundColor ?? AppColors.primary),
            foregroundColor: WidgetStateProperty.all(textColor ?? Colors.white),
          ),
          child: _buildChild(),
        );
      case ButtonType.secondary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: CustomButtonStyles.secondary.copyWith(
            backgroundColor: WidgetStateProperty.all(backgroundColor ?? AppColors.secondary),
            foregroundColor: WidgetStateProperty.all(textColor ?? Colors.white),
          ),
          child: _buildChild(),
        );
      case ButtonType.danger:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: CustomButtonStyles.danger.copyWith(
            backgroundColor: WidgetStateProperty.all(backgroundColor ?? AppColors.danger),
            foregroundColor: WidgetStateProperty.all(textColor ?? Colors.white),
          ),
          child: _buildChild(),
        );
      case ButtonType.outline:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: CustomButtonStyles.outline.copyWith(
            side: WidgetStateProperty.all(
              BorderSide(color: backgroundColor ?? AppColors.primary)
            ),
            foregroundColor: WidgetStateProperty.all(textColor ?? AppColors.primary),
          ),
          child: _buildChild(),
        );
      case ButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: CustomButtonStyles.text.copyWith(
            foregroundColor: WidgetStateProperty.all(textColor ?? AppColors.primary),
          ),
          child: _buildChild(),
        );
    }
  }

  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }

    return Text(text);
  }
}

enum ButtonType {
  primary,
  secondary,
  danger,
  outline,
  text,
}