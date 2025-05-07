import 'package:flutter/material.dart';

/// A reusable loading indicator widget for the application
class AppLoader extends StatelessWidget {
  /// Creates an AppLoader widget
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator();
  }
}
