import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool isPassword;
  final bool isEmail;
  final bool isRequired;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool isNumber;
  final bool isMultiline;
  final int? maxLines;
  final int? minLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final String? initialValue;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.isPassword = false,
    this.isEmail = false,
    this.isRequired = false,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
    this.isNumber = false,
    this.isMultiline = false,
    this.maxLines = 1,
    this.minLines = 1,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.initialValue,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword && !widget.obscureText;
    _controller = widget.controller ?? TextEditingController();
    if (widget.initialValue != null && _controller.text.isEmpty) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.gray700,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _controller,
          obscureText: _obscureText,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          maxLines: widget.isMultiline ? (widget.maxLines ?? 3) : widget.maxLines,
          minLines: widget.isMultiline ? (widget.minLines ?? 1) : widget.minLines,
          keyboardType: widget.isNumber 
              ? TextInputType.number 
              : (widget.isEmail 
                  ? TextInputType.emailAddress 
                  : (widget.keyboardType ?? TextInputType.text)),
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppColors.gray900,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.gray400,
            ),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.isPassword 
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.gray400,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : widget.suffixIcon,
            filled: true,
            fillColor: widget.readOnly 
                ? AppColors.gray100 
                : AppColors.gray50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.danger, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            errorStyle: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.danger,
            ),
          ),
          validator: widget.validator,
        ),
      ],
    );
  }
}