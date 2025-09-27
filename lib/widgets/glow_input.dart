import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class GlowInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onSearch;
  final ValueChanged<String>? onSubmitted;
  final PhosphorIconData? prefixIcon;
  final PhosphorIconData? suffixIcon;
  final Color glowColor;
  final Color textColor;
  final Color backgroundColor;

  const GlowInput({
    super.key,
    required this.controller,
    this.hintText = "Buscar...",
    this.onSearch,
    this.onSubmitted,
    this.prefixIcon = PhosphorIconsRegular.magnifyingGlass,
    this.suffixIcon = PhosphorIconsRegular.arrowRight,
    this.glowColor = Colors.greenAccent,
    this.textColor = Colors.greenAccent,
    this.backgroundColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.5),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: textColor.withValues(alpha: 0.5)),
          prefixIcon: prefixIcon != null
              ? PhosphorIcon(prefixIcon!, color: glowColor)
              : null,
          suffixIcon: suffixIcon != null
              ? IconButton(
                  icon: PhosphorIcon(suffixIcon!, color: glowColor),
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty && onSearch != null) {
                      onSearch!();
                    }
                  },
                )
              : null,
          filled: true,
          fillColor: backgroundColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: glowColor, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: glowColor, width: 2),
          ),
        ),
        onSubmitted: (value) {
          if (value.trim().isNotEmpty && onSubmitted != null) {
            onSubmitted!(value.trim());
          }
        },
      ),
    );
  }
}
