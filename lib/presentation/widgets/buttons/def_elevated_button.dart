import 'package:flutter/material.dart';

class DefElevatedButton extends StatelessWidget {
  const DefElevatedButton({
    super.key,
    required this.title,
    required this.onPressed,
  });
  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: Text(title));
  }
}
