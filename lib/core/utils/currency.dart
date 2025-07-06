enum Currency {
  som(name: 'Som', symbol: 'KGS', code: 'KGS'),
  usd(name: 'USD', symbol: '\$', code: 'USD'),
  rub(name: 'RUB', symbol: '₽', code: 'RUB'),
  kzt(name: 'Tenge', symbol: '₸', code: 'TEN'),
  eur(name: 'EUR', symbol: '€', code: 'UE');

  final String name;
  final String symbol;
  final String code;

  const Currency({
    required this.name,
    required this.symbol,
    required this.code,
  });

  static Currency fromCode(String code) {
    return Currency.values.firstWhere((e) => e.code == code);
  }

  static Currency fromSymbol(String symbol) {
    return Currency.values.firstWhere((e) => e.symbol == symbol);
  }
}
