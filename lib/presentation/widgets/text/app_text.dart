//ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

enum TextType { header, body, title, subtitle, description, title20, title24 }

class AppText extends StatelessWidget {
  const AppText({
    super.key,
    this.fontWeight,
    required this.title,
    this.maxLines,
    this.color,
    this.overflow,
    this.textAlign,
    required this.textType,
    this.textDirection,
    this.decoration,
    this.decorationColor,
  });

  final FontWeight? fontWeight;
  final String title;
  final int? maxLines;
  final Color? color;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final TextType textType;
  final TextDirection? textDirection;
  final TextDecoration? decoration;
  final Color? decorationColor;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = getTextStyle(textType, context);

    if (fontWeight != null) {
      textStyle = textStyle.copyWith(fontWeight: fontWeight);
    }

    Color? textColor = color ?? textStyle.color;

    return Text(
      title,
      overflow: overflow,
      maxLines: maxLines,
      textDirection: textDirection,
      textAlign: textAlign ?? TextAlign.start,
      style: textStyle.copyWith(
        color: textColor,
        fontWeight: fontWeight,
        decoration: decoration,
        decorationColor: decorationColor,
      ),
    );
  }

  TextStyle getTextStyle(TextType type, BuildContext context) {
    final theme = Theme.of(context).textTheme;
    switch (type) {
      case TextType.header:
        return theme.titleLarge!.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        );

      case TextType.body:
        return theme.titleMedium!.copyWith(fontWeight: FontWeight.w400);

      case TextType.title:
        return theme.titleLarge!.copyWith(fontWeight: FontWeight.w600);

      case TextType.title20:
        return theme.titleLarge!.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        );
      case TextType.title24:
        return theme.headlineMedium!.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 24,
        );
      case TextType.subtitle:
        return theme.labelLarge!.copyWith(fontWeight: FontWeight.w400);

      case TextType.description:
        return theme.labelMedium!.copyWith(fontWeight: FontWeight.w400);
    }
  }
}
