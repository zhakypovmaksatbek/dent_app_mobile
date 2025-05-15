import 'package:flutter/material.dart';

/// Widget for displaying a page title with consistent styling
class PageTitleWidget extends StatelessWidget {
  final String title;
  final TextStyle? style;

  const PageTitleWidget({super.key, required this.title, this.style});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style:
          style ?? const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}
