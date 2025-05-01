import 'package:dent_app_mobile/presentation/theme/extension/card_style_extension.dart';
import 'package:flutter/material.dart';

class CustomCardDecoration extends StatelessWidget {
  const CustomCardDecoration({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardStyle = theme.extension<CardStyleExtension>();
    final decoration =
        cardStyle?.customCardDecoration ??
        CardStyleExtension.defaultCardDecoration;
    return Container(decoration: decoration, child: child);
  }
}
