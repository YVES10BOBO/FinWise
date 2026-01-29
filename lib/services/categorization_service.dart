import '../models/transaction.dart';

/// Automatic transaction categorization service
/// This will be enhanced with AI/ML later, but works with rules for now
class CategorizationService {
  /// Automatically categorize a transaction based on description and amount
  static Category categorizeTransaction(String description, double amount) {
    final lowerDesc = description.toLowerCase();

    // Income patterns
    if (lowerDesc.contains('salary') ||
        lowerDesc.contains('income') ||
        lowerDesc.contains('payment') ||
        lowerDesc.contains('wage')) {
      return Category.income;
    }

    // Food patterns
    if (lowerDesc.contains('food') ||
        lowerDesc.contains('restaurant') ||
        lowerDesc.contains('cafe') ||
        lowerDesc.contains('pizza') ||
        lowerDesc.contains('grocery') ||
        lowerDesc.contains('supermarket') ||
        lowerDesc.contains('market') ||
        lowerDesc.contains('eat') ||
        lowerDesc.contains('meal')) {
      return Category.food;
    }

    // Transport patterns
    if (lowerDesc.contains('taxi') ||
        lowerDesc.contains('uber') ||
        lowerDesc.contains('transport') ||
        lowerDesc.contains('bus') ||
        lowerDesc.contains('fuel') ||
        lowerDesc.contains('gas') ||
        lowerDesc.contains('parking')) {
      return Category.transport;
    }

    // Entertainment patterns
    if (lowerDesc.contains('movie') ||
        lowerDesc.contains('cinema') ||
        lowerDesc.contains('entertainment') ||
        lowerDesc.contains('game') ||
        lowerDesc.contains('netflix') ||
        lowerDesc.contains('spotify') ||
        lowerDesc.contains('music')) {
      return Category.entertainment;
    }

    // Utilities patterns
    if (lowerDesc.contains('electricity') ||
        lowerDesc.contains('water') ||
        lowerDesc.contains('internet') ||
        lowerDesc.contains('wifi') ||
        lowerDesc.contains('airtime') ||
        lowerDesc.contains('mobile') ||
        lowerDesc.contains('phone') ||
        lowerDesc.contains('utility')) {
      return Category.utilities;
    }

    // Rent patterns
    if (lowerDesc.contains('rent') ||
        lowerDesc.contains('house') ||
        lowerDesc.contains('apartment') ||
        lowerDesc.contains('accommodation')) {
      return Category.rent;
    }

    // Shopping patterns
    if (lowerDesc.contains('shop') ||
        lowerDesc.contains('store') ||
        lowerDesc.contains('buy') ||
        lowerDesc.contains('purchase') ||
        lowerDesc.contains('mall')) {
      return Category.shopping;
    }

    // Health patterns
    if (lowerDesc.contains('hospital') ||
        lowerDesc.contains('clinic') ||
        lowerDesc.contains('pharmacy') ||
        lowerDesc.contains('doctor') ||
        lowerDesc.contains('medicine')) {
      return Category.health;
    }

    // Education patterns
    if (lowerDesc.contains('school') ||
        lowerDesc.contains('tuition') ||
        lowerDesc.contains('fees') ||
        lowerDesc.contains('university') ||
        lowerDesc.contains('college')) {
      return Category.education;
    }

    // Debt / loan patterns
    if (lowerDesc.contains('loan') ||
        lowerDesc.contains('debt') ||
        lowerDesc.contains('credit') ||
        lowerDesc.contains('installment')) {
      return Category.debt;
    }

    // Giving / charity patterns
    if (lowerDesc.contains('tithe') ||
        lowerDesc.contains('offering') ||
        lowerDesc.contains('church') ||
        lowerDesc.contains('donation') ||
        lowerDesc.contains('charity')) {
      return Category.giving;
    }

    // Default to food if amount is small (likely food expense)
    if (amount < 50000) {
      return Category.food;
    }

    // Default category
    return Category.shopping;
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
