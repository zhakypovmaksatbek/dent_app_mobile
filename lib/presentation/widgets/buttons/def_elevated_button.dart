import 'package:flutter/material.dart';

class DefElevatedButton extends StatelessWidget {
  const DefElevatedButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
  });
  final String title;
  final VoidCallback onPressed;
  final double? minWidth;
  final double? minHeight;
  final double? maxWidth;
  final double? maxHeight;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        maximumSize: Size(maxWidth ?? double.infinity, maxHeight ?? 45),
        minimumSize: Size(minWidth ?? double.infinity, minHeight ?? 45),
      ),
      onPressed: onPressed,
      child: Text(title),
    );
  }
}
