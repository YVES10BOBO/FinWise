import '../models/transaction.dart';

/// Automatic transaction categorization.
///
/// Rule-based for now (no paid AI needed). It scans the given text for known
/// keywords / Rwandan biller & merchant names and returns the first matching
/// category. For SMS-detected transactions, pass the FULL message body so
/// words like "Cash Power" or "airtime" are visible — not just the short
/// counterparty description.
///
/// Order matters: the first group that matches wins, so more specific groups
/// (utilities, health) are checked before broad ones (shopping).
class CategorizationService {
  static Category categorizeTransaction(
    String text,
    double amount, {
    TransactionType? type,
  }) {
    final t = text.toLowerCase();

    // 1. Direction first: money coming in is Income unless it's clearly
    //    something else (a refunded purchase etc. is rare — treat as income).
    if (type == TransactionType.income) {
      return Category.income;
    }

    // 2. Income keywords (when direction is unknown).
    if (_any(t, ['salary', 'income', 'wage', 'payroll'])) {
      return Category.income;
    }

    // 3. Utilities — electricity, water, airtime/data, internet.
    //    Rwanda billers: Cash Power (electricity), WASAC (water), REG/EUCL.
    if (_any(t, [
      'cash power', 'cashpower', 'electricity', 'eucl', 'umeme',
      'wasac', 'water bill', 'water',
      // 'mb ' / 'gb ' / 'reg ' were removed: two-letter fragments match far
      // too much ordinary text (any word ending in "mb", a stray "reg"), and
      // they were part of why a service notice got filed under utilities.
      'airtime', 'bundle', 'data bundle',
      'internet', 'wifi', 'canalbox', 'liquid', 'utility',
    ])) {
      return Category.utilities;
    }

    // 4. TV / entertainment subscriptions.
    if (_any(t, [
      'startimes', 'canal+', 'canal +', 'canalplus', 'dstv', 'gotv',
      'netflix', 'spotify', 'showmax', 'cinema', 'movie', 'music', 'game',
      'entertainment', 'bet', 'betting', 'lottery',
    ])) {
      return Category.entertainment;
    }

    // 5. Transport / fuel.
    if (_any(t, [
      'taxi', 'uber', 'yego', 'bolt', 'move', 'moto', 'bus', 'ticket',
      'fuel', 'petrol', 'diesel', 'gas station', 'engen', 'kobil',
      'total energies', 'sp ', 'parking', 'transport',
    ])) {
      return Category.transport;
    }

    // 6. Health / pharmacy.
    if (_any(t, [
      'hospital', 'clinic', 'pharmacy', 'pharmacie', 'doctor', 'medicine',
      'medical', 'chuk', 'king faisal', 'rssb', 'mutuelle', 'health',
    ])) {
      return Category.health;
    }

    // 7. Education / school fees.
    if (_any(t, [
      'school', 'tuition', 'university', 'college', 'campus', 'reb',
      'student', 'academic', 'exam', 'education',
    ])) {
      return Category.education;
    }

    // 8. Food / groceries / restaurants.
    if (_any(t, [
      'food', 'restaurant', 'resto', 'cafe', 'coffee', 'pizza', 'grocery',
      'supermarket', 'market', 'bakery', 'meal', 'lunch', 'dinner',
      'simba', 'nakumatt', 'la galette',
    ])) {
      return Category.food;
    }

    // 9. Rent / housing.
    if (_any(t, ['rent', 'landlord', 'apartment', 'accommodation', 'lease'])) {
      return Category.rent;
    }

    // 10. Giving / church / donation.
    if (_any(t, ['tithe', 'offering', 'church', 'donation', 'charity', 'ministry'])) {
      return Category.giving;
    }

    // 11. Debt / loans.
    if (_any(t, ['loan', 'debt', 'credit', 'installment', 'repay', 'saccos'])) {
      return Category.debt;
    }

    // 12. Fees & taxes.
    if (_any(t, ['tax', 'rra', 'irembo', 'fine', 'penalty', 'levy'])) {
      return Category.fees;
    }

    // 13. Shopping / general merchant purchases.
    if (_any(t, ['shop', 'store', 'buy', 'purchase', 'mall', 'boutique', 'market'])) {
      return Category.shopping;
    }

    // 14. Nothing recognized — stay neutral ("Other" / transfer icon) rather
    //     than mislabeling a person-to-person transfer.
    return Category.other;
  }

  /// True if [text] contains any of [needles].
  static bool _any(String text, List<String> needles) {
    for (final n in needles) {
      if (text.contains(n)) return true;
    }
    return false;
  }

  /// Analyze spending patterns and suggest category
  static Map<Category, double> analyzeSpendingPatterns(
      List<Transaction> transactions) {
    final Map<Category, double> categoryTotals = {};

    for (var transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        categoryTotals[transaction.category] =
            (categoryTotals[transaction.category] ?? 0) + transaction.amount;
      }
    }

    return categoryTotals;
  }
}
