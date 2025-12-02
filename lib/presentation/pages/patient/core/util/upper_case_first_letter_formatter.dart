import 'package:flutter/services.dart';

class UpperCaseFirstLetterFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    String newText =
        newValue.text[0].toUpperCase() + newValue.text.substring(1);

    return newValue.copyWith(text: newText, selection: newValue.selection);
  }
}
