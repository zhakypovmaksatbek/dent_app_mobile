import 'package:flutter/material.dart';

class AppBottomSheet {
  static Future<void> showBottomSheet(
    BuildContext context,
    Widget child,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(child: child),
    );
  }
}
