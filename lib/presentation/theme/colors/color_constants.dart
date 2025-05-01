import 'package:flutter/material.dart';

final class ColorConstants {
  static const Color primary = Color(0xff624DC2);
  static const Color secondary = Color(0xff64B5F6);
  static const Color accent = Color(0xff03A9F4);
  static const Color background = Color(0xffF5F5F5);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xff212121);
  static const Color textSecondary = Color(0xff757575);
  static const Color divider = Color(0xffBDBDBD);
  static const Color success = Color(0xff4CAF50);
  static const Color error = Color(0xffE53935);
  static const Color warning = Color(0xffFFC107);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xff000000);
  static const Color grey = Color(0xff808080);
  static const Color lightGrey = Color(0xffD3D3D3);
  static const Color darkGrey = Color(0xffA9A9A9);
  static const Color blue = Color(0xff0000FF);
  static const Color red = Color(0xFFFF0000);
  static const Color green = Color(0xff00FF00);

  static const Color cash = Color(0xFF43A047);
  static const Color card = Color(0xFF1E88E5);
  static const Color transfer = Color(0xFF7B1FA2);
  static const Color mbank = Color(0xFF7B1FA2);
  static const Color optima = Color(0xFFEF6C00);
}

// Extension to add opacity values (for backward compatibility with AppColors)

// TypeDef to maintain backwards compatibility
typedef AppColors = ColorConstants;
