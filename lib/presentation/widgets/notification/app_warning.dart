import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class AppWarning {
  static void showToastWarning(
    BuildContext context,
    String message, {
    ToastificationType? type,
    Color? backgroundColor,
  }) {
    toastification.show(
      context: context, // optional if you use ToastificationWrapper
      title: AppText(title: message, textType: TextType.body, maxLines: 3),
      autoCloseDuration: const Duration(seconds: 5),
      type: type,
      backgroundColor: backgroundColor,
    );
  }
}
