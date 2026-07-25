/// Supported currencies for FinWise.
///
/// Kept intentionally simple: each user picks ONE home currency for their
/// account. All of their amounts are stored and displayed in that currency.
/// There is no cross-currency conversion, because transactions are private
/// per-user (nobody needs to compare amounts across different users'
/// currencies), so this needs no exchange-rate API and stays free to run.
enum AppCurrency {
  rwf('RWF', 'RWF', 'Rwandan Franc', 0),
  usd('USD', '\$', 'US Dollar', 2),
  eur('EUR', '€', 'Euro', 2),
  gbp('GBP', '£', 'British Pound', 2),
  kes('KES', 'KSh', 'Kenyan Shilling', 2),
  ugx('UGX', 'USh', 'Ugandan Shilling', 0),
  tzs('TZS', 'TSh', 'Tanzanian Shilling', 0),
  ngn('NGN', '₦', 'Nigerian Naira', 2),
  ghs('GHS', 'GH₵', 'Ghanaian Cedi', 2),
  zar('ZAR', 'R', 'South African Rand', 2),
  xaf('XAF', 'FCFA', 'Central African CFA Franc', 0),
  cad('CAD', 'C\$', 'Canadian Dollar', 2),
  inr('INR', '₹', 'Indian Rupee', 2);

  /// ISO-style code, also used as the storage key (SharedPreferences / Firestore).
  final String code;

  /// Symbol/prefix shown next to amounts.
  final String symbol;

  /// Human-readable name shown in pickers.
  final String label;

  /// How many decimal places to show (most East African currencies use 0).
  final int decimalDigits;

  const AppCurrency(this.code, this.symbol, this.label, this.decimalDigits);

  static AppCurrency fromCode(String? code) {
    if (code == null) return AppCurrency.rwf;
    return AppCurrency.values.firstWhere(
      (c) => c.code == code,
      orElse: () => AppCurrency.rwf,
    );
  }
}
