import 'package:dent_app_mobile/core/data/app_data_service.dart';
import 'package:easy_localization/easy_localization.dart';

class FormatPrice {
  static String formatPrice(String? price) {
    if (price == null || price.isEmpty) return "";

    if (price.endsWith('.00')) {
      return price.substring(0, price.length - 3);
    } else if (price.endsWith('.0')) {
      return price.substring(0, price.length - 2);
    }

    return price;
  }
}

extension PriceFormat on double {
  Future<String> toCurrencyFormat({
    String locale = 'ru_RU',
    String? symbol,
    bool showSymbol = false,
  }) async {
    final numberFormatter = NumberFormat('#,##0.##', locale);
    final String formattedNumber = numberFormatter.format(this);

    if (showSymbol) {
      // SharedPreferences'tan currency symbol'ı al
      final currencySymbol =
          symbol ?? (await AppDataService.instance.getCurrency()).symbol;
      return '$formattedNumber\u00A0$currencySymbol';
    } else {
      return formattedNumber;
    }
  }
}

extension PriceFormatFromString on String {
  Future<String> toCurrencyFormat({
    String locale = 'ru_RU',
    String? symbol,
    bool showSymbol = false,
  }) async {
    // Parse the string to double first
    final double? parsedValue = double.tryParse(this);
    if (parsedValue == null) {
      return this; // Return original string if parsing fails
    }

    final numberFormatter = NumberFormat('#,##0.##', locale);
    final String formattedNumber = numberFormatter.format(parsedValue);

    if (showSymbol) {
      // SharedPreferences'tan currency symbol'ı al
      final currencySymbol =
          symbol ?? (await AppDataService.instance.getCurrency()).symbol;
      return '$formattedNumber\u00A0$currencySymbol';
    } else {
      return formattedNumber;
    }
  }
}
