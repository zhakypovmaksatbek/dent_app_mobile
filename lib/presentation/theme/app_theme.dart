import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/theme/extension/card_style_extension.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    extensions: [
      CardStyleExtension(
        customCardDecoration: CardStyleExtension.defaultCardDecoration,
      ),
    ],
    primaryColor: ColorConstants.primary,
    scaffoldBackgroundColor: ColorConstants.white,
    colorScheme: ColorScheme.fromSeed(
      primary: ColorConstants.primary,
      secondary: ColorConstants.secondary,
      surface: ColorConstants.white,
      seedColor: ColorConstants.white,
      error: ColorConstants.red,
    ),
    cardColor: ColorConstants.secondary,
    cardTheme: CardTheme(
      color: ColorConstants.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ColorConstants.white,
      surfaceTintColor: AppColors.white,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: ColorConstants.white,
      selectedItemColor: ColorConstants.primary,
      unselectedItemColor: ColorConstants.grey,
      selectedLabelStyle: TextStyle(color: ColorConstants.primary),
      unselectedLabelStyle: TextStyle(color: ColorConstants.grey),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorConstants.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: ColorConstants.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: ColorConstants.white,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: ColorConstants.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: ColorConstants.primary,
      foregroundColor: Colors.white,
    ),
  );
}
