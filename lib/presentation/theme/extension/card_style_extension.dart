import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:flutter/material.dart';

@immutable
class CardStyleExtension extends ThemeExtension<CardStyleExtension> {
  const CardStyleExtension({required this.customCardDecoration});

  final BoxDecoration customCardDecoration;

  @override
  ThemeExtension<CardStyleExtension> lerp(
    covariant ThemeExtension<CardStyleExtension>? other,
    double t,
  ) {
    if (other is! CardStyleExtension) {
      return this;
    }
    return CardStyleExtension(
      customCardDecoration:
          BoxDecoration.lerp(
            customCardDecoration,
            other.customCardDecoration,
            t,
          )!,
    );
  }

  @override
  CardStyleExtension copyWith({BoxDecoration? customCardDecoration}) {
    return CardStyleExtension(
      customCardDecoration: customCardDecoration ?? this.customCardDecoration,
    );
  }

  @override
  int get hashCode => customCardDecoration.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardStyleExtension &&
          runtimeType == other.runtimeType &&
          customCardDecoration == other.customCardDecoration;

  static BoxDecoration defaultCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16.0),
    boxShadow: [
      BoxShadow(
        color: ColorConstants.grey.withValues(alpha: 0.15),
        spreadRadius: 1,
        blurRadius: 6,
        offset: const Offset(0, 3),
      ),
    ],
  );

  static BoxDecoration defaultDarkCardDecoration = BoxDecoration(
    color: const Color(0xFF2a2a2a),
    borderRadius: BorderRadius.circular(16.0),
    boxShadow: [
      BoxShadow(
        color: ColorConstants.black.withValues(alpha: 0.3),
        spreadRadius: 1,
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
