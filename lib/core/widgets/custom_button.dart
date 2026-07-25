import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double? height;
  final IconData? icon;

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
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height ?? 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: _getButtonStyle(),
        child: _buildChild(),
      ),
    );
  }

  ButtonStyle _getButtonStyle() {
    Color backgroundColor;
    Color foregroundColor = Colors.white;
    
    switch (type) {
      case ButtonType.primary:
        backgroundColor = AppColors.primary;
        break;
      case ButtonType.secondary:
        backgroundColor = AppColors.secondary;
        break;
      case ButtonType.danger:
        backgroundColor = AppColors.danger;
        break;
      case ButtonType.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.primary;
        break;
      case ButtonType.text:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.primary;
        break;
    }

    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: type == ButtonType.outline || type == ButtonType.text ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: type == ButtonType.outline
            ? const BorderSide(color: AppColors.primary)
            : BorderSide.none,
      ),
      textStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildChild() {
    if (isLoading) {
      return SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: type == ButtonType.outline || type == ButtonType.text
              ? AppColors.primary
              : Colors.white,
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