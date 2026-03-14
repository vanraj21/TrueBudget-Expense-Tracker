class CurrencyOption {
  final String code;
  final String symbol;
  final String name;

  const CurrencyOption({
    required this.code,
    required this.symbol,
    required this.name,
  });
}

const List<CurrencyOption> supportedCurrencies = [
  CurrencyOption(code: 'INR', symbol: '₹', name: 'Indian Rupee'),
  CurrencyOption(code: 'USD', symbol: '\$', name: 'US Dollar'),
  CurrencyOption(code: 'EUR', symbol: '€', name: 'Euro'),
  CurrencyOption(code: 'GBP', symbol: '£', name: 'British Pound'),
  CurrencyOption(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
  CurrencyOption(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar'),
  CurrencyOption(code: 'CAD', symbol: 'C\$', name: 'Canadian Dollar'),
];

String getCurrencySymbol(String code) {
  final found = supportedCurrencies.firstWhere(
    (c) => c.code == code,
    orElse: () => supportedCurrencies.first,
  );
  return found.symbol;
}
