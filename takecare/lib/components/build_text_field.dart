import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:takecare/constants/app_theme.dart';

class BuildTextField extends StatelessWidget {
  const BuildTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.isRequired = false,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.icon,
    this.placeholder
  });

  final TextEditingController controller;
  final String hint;
  final bool isRequired;
  final int maxLines;
  final IconData? icon;
  final String? placeholder;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLength: maxLength,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: TextStyle(
          color: AppTheme.subtitle,
          fontSize: 14,
        ),
        counterText: "",
        prefixIcon: icon != null ? Icon(icon) : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1,
          ),
        ),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'กรุณากรอก$hint'; // "Please enter [hint]"
        }
        return null;
      },
    );
  }
}
