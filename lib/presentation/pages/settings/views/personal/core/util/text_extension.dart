extension TextExtension on double {
  String toIntString() {
    return this % 1 == 0 ? toInt().toString() : toString();
  }
}
