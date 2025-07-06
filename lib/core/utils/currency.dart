import 'package:dent_app_mobile/core/data/app_data_service.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';

enum Currency {
  som(name: LocaleKeys.currency_som, symbol: 'KGS', code: 'SOM'),
  usd(name: LocaleKeys.currency_usd, symbol: '\$', code: 'USD'),
  rub(name: LocaleKeys.currency_rub, symbol: '₽', code: 'RUB'),
  kzt(name: LocaleKeys.currency_kzt, symbol: '₸', code: 'TEN'),
  eur(name: LocaleKeys.currency_eur, symbol: '€', code: 'UE');

  final String name;
  final String symbol;
  final String code;

  const Currency({
    required this.name,
    required this.symbol,
    required this.code,
  });

  static Currency fromCode(String code) {
    return Currency.values.firstWhere(
      (e) => e.code == code,
      orElse: () => Currency.som,
    );
  }

  static Currency fromSymbol(String symbol) {
    return Currency.values.firstWhere(
      (e) => e.symbol == symbol,
      orElse: () => Currency.som,
    );
  }
}

extension CurrencyExtension on num {
  /// Async version - for when you need to get currency from storage
  Future<String> toCurrency() async {
    final currency = await AppDataService.instance.getCurrency();
    return "${_formatWithSpaces()} ${currency.symbol}";
  }

  String _formatWithSpaces() {
    // Convert to int if it's a whole number, otherwise keep 2 decimal places
    if (this == roundToDouble()) {
      return toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]} ',
      );
    } else {
      return toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]} ',
      );
    }
  }
}
