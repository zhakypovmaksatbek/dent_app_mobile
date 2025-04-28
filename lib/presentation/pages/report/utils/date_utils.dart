import 'package:easy_localization/easy_localization.dart';

class ReportDateUtils {
  /// Formats a DateTime to 'yyyy-MM-dd' format for API requests
  static String formatForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Formats a DateTime to 'd MMM yyyy' format for display
  static String formatForDisplay(DateTime date) {
    return DateFormat('d MMM yyyy').format(date);
  }

  /// Formats a DateTime string from API to display format
  static String formatDateTimeString(
    String? dateTimeString, {
    String format = 'dd MMM yyyy, HH:mm',
  }) {
    if (dateTimeString == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat(format).format(dateTime);
    } catch (e) {
      return 'Invalid date';
    }
  }
}
