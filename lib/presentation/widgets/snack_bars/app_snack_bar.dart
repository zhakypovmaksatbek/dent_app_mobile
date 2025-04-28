import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';

class AppSnackBar {
  static void showErrorSnackBar(BuildContext context, String message) {
    CherryToast.error(
      description: Text(message),
      animationType: AnimationType.fromTop,
      displayCloseButton: false,
    ).show(context);
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    CherryToast.success(
      description: Text(message),
      animationType: AnimationType.fromTop,
      displayCloseButton: false,
    ).show(context);
  }
}
