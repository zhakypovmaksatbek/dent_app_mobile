import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:flutter/material.dart';

class CustomCloseButton extends StatelessWidget {
  const CustomCloseButton({super.key, this.onPressed, this.color});
  final void Function()? onPressed;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return CloseButton(
      style: ButtonStyle(
        shape: const WidgetStatePropertyAll(CircleBorder()),
        backgroundColor: WidgetStateProperty.all(
          AppColors.lightGrey.withValues(alpha: .2),
        ),
        iconColor: WidgetStateProperty.all(color),
        foregroundColor: WidgetStateProperty.all(AppColors.darkGrey),
        minimumSize: WidgetStateProperty.all(const Size(30, 30)),
        iconSize: WidgetStateProperty.all(18),
        padding: WidgetStateProperty.all(EdgeInsets.zero),
      ),
      onPressed: onPressed,
    );
  }
}
