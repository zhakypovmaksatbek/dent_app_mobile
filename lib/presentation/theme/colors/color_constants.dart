import 'package:flutter/material.dart';

final class ColorConstants {
  static const Color primary = Color.fromRGBO(13, 71, 161, 1);
  static const Color secondary = Color(0xFF64B5F6);
  static const Color accent = Color(0xFF03A9F4);
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFBDBDBD);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFC107);

  // Temel renkler
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF808080);
  static const Color lightGrey = Color(0xFFD3D3D3);
  static const Color darkGrey = Color(0xFFA9A9A9);
  static const Color blue = Color(0xFF0000FF);
  static const Color red = Color(0xFFFF0000);
  static const Color green = Color(0xFF00FF00);

  // Ödeme yöntemi renkleri
  static const Color cash = Color(0xFF43A047);
  static const Color card = Color(0xFF1E88E5);
  static const Color transfer = Color(0xFF7B1FA2);
  static const Color mbank = Color(0xFF7B1FA2);
  static const Color optima = Color(0xFFEF6C00);
}

// Extension to add opacity values (for backward compatibility with AppColors)
extension ColorConstantsExtension on Color {
  Color withValues({double? alpha}) {
    return withOpacity(alpha ?? 1.0);
  }
}

// TypeDef to maintain backwards compatibility
typedef AppColors = ColorConstants;
