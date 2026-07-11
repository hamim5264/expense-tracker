class CurrencyService {
  static const Map<String, String> _currencySymbols = {
    'USD': r'$',
    'BDT': '৳',
    'EUR': '€',
    'GBP': '£',
    'INR': '₹',
    'CAD': r'CA$',
    'AUD': r'A$',
  };

  static String getSymbol(String currencyCode) {
    return _currencySymbols[currencyCode.toUpperCase()] ?? currencyCode;
  }

  static String format(double amount, String currencyCode) {
    final symbol = getSymbol(currencyCode);
    final formattedAmount = amount.toStringAsFixed(2);
    if (currencyCode.toUpperCase() == 'BDT') {
      return '$symbol $formattedAmount';
    }
    return '$symbol$formattedAmount';
  }

  static List<String> get supportedCurrencies => _currencySymbols.keys.toList();
}
