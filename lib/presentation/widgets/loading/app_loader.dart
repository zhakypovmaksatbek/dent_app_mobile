import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:flutter/material.dart';

class AppLoader extends StatelessWidget {
  final double size;
  final Color color;

  const AppLoader({
    super.key,
    this.size = 40.0,
    this.color = ColorConstants.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color),
        strokeWidth: 3.0,
      ),
    );
  }
}
