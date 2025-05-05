import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DefTextField extends StatelessWidget {
  const DefTextField({
    super.key,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction,
    this.keyboardAppearance,
    this.onEditingComplete,
    this.onChanged,
    this.labelText,
    this.decoration,
  });
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final Brightness? keyboardAppearance;
  final VoidCallback? onEditingComplete;
  final Function(String)? onChanged;
  final String? labelText;
  final InputDecoration? decoration;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText,
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      keyboardAppearance: keyboardAppearance,
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
      onChanged: onChanged,
      decoration:
          decoration ??
          InputDecoration(
            hintText: hintText,
            labelText: labelText,
            border: InputBorder.none,
          ),
    );
  }
}
