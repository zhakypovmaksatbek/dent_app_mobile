extension StringExtension on String {
  String toPhoneNumber() {
    if (length != 12) {
      return this;
    }
    final countryCode = substring(0, 3);
    final operatorCode = substring(3, 6);
    final firstPart = substring(6, 9);
    final secondPart = substring(9, 12);
    return '+$countryCode ($operatorCode) $firstPart-$secondPart';
  }
}

extension NullableStringExtension on String? {
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;
}
