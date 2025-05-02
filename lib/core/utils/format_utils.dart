class FormatUtils {
  /// Formats a phone number into a readable format
  ///
  /// Example formats:
  /// - 996204904599 -> +996 (204) 904-599
  /// - 905554443322 -> +90 (555) 444-3322
  ///
  /// You can customize the format by providing separator parameters
  static String formatPhoneNumber(
    String phoneNumber, {
    String countryCodeSeparator = ' ',
    String areaCodePrefix = '(',
    String areaCodeSuffix = ')',
    String areaCodeSeparator = ' ',
    String middleSeparator = ' ',
    String lastSeparator = '-',
  }) {
    // Clean the input (remove non-digit characters)
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    if (cleanNumber.isEmpty) return '';

    // Handle different country code lengths (usually 1-3 digits)
    // Most common: +1 (US), +44 (UK), +90 (TR), +996 (KG)
    int countryCodeLength = 3; // Default for many countries

    // Format the phone number based on its length
    if (cleanNumber.length < 4) {
      // Too short, just return as is with + prefix
      return '+$cleanNumber';
    }

    // Extract parts
    final countryCode = cleanNumber.substring(0, countryCodeLength);

    // Determine area code length (typically 3 digits)
    int areaCodeLength = 3;

    // For shorter numbers, adjust the lengths
    if (cleanNumber.length < countryCodeLength + areaCodeLength + 4) {
      // Not enough digits for standard format, use a simpler one
      final remaining = cleanNumber.substring(countryCodeLength);
      return '+$countryCode$countryCodeSeparator$remaining';
    }

    final areaCode = cleanNumber.substring(
      countryCodeLength,
      countryCodeLength + areaCodeLength,
    );

    // Split the remaining digits
    final remainingDigits = cleanNumber.substring(
      countryCodeLength + areaCodeLength,
    );

    // Format the middle and last parts based on the length
    String formattedNumber = '';

    if (remainingDigits.length <= 4) {
      // If remaining digits are 4 or fewer, just add them as is
      formattedNumber = remainingDigits;
    } else {
      // Split into middle and last parts (for longer numbers)
      final middlePart = remainingDigits.substring(0, 3);
      final lastPart = remainingDigits.substring(3);
      formattedNumber = '$middlePart$lastSeparator$lastPart';
    }

    // Combine all parts with proper formatting
    return '+$countryCode$countryCodeSeparator$areaCodePrefix$areaCode$areaCodeSuffix$areaCodeSeparator$formattedNumber';
  }
}
