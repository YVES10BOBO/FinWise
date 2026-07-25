import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/currency.dart';
import 'categorization_service.dart';

/// Budget recommendation service
/// Provides AI-like recommendations based on spending patterns
/// Will be enhanced with actual AI/ML backend later
class BudgetRecommendationService {
  /// Generate smart budget recommendations based on income and spending patterns
  static Map<Category, double> generateBudgetRecommendations(
    double monthlyIncome,
    List<Transaction> transactions,
  ) {
    // Analyze current spending
    final spendingPatterns = CategorizationService.analyzeSpendingPatterns(
        transactions);

    // Default budget percentages (can be adjusted by AI later)
    final defaultPercentages = {
      Category.food: 0.30, // 30%
      Category.transport: 0.15, // 15%
      Category.entertainment: 0.10, // 10%
      Category.utilities: 0.15, // 15%
      Category.rent: 0.15, // 15%
      Category.shopping: 0.10, // 10%
      Category.savings: 0.20, // 20% (recommended savings)
    };

    // Calculate recommended budgets
    final Map<Category, double> recommendations = {};

    for (var entry in defaultPercentages.entries) {
      if (entry.key != Category.savings) {
        recommendations[entry.key] = monthlyIncome * entry.value;
      }
    }

    // Adjust based on actual spending patterns if available
    if (spendingPatterns.isNotEmpty) {
      final totalSpent = spendingPatterns.values.fold(0.0, (a, b) => a + b);
      
      for (var category in spendingPatterns.keys) {
        final currentPercentage = spendingPatterns[category]! / totalSpent;
        final recommendedPercentage = defaultPercentages[category] ?? 0.10;
        
        // If user is spending way more than recommended, suggest reduction
        if (currentPercentage > recommendedPercentage * 1.2) {
          recommendations[category] = monthlyIncome * recommendedPercentage;
        } else {
          // Otherwise, use their current spending as baseline
          recommendations[category] = spendingPatterns[category]!;
        }
      }
    }

    return recommendations;
  }

  /// Get budget recommendations as Budget objects
  static List<Budget> getBudgetRecommendations(
    double monthlyIncome,
    List<Transaction> transactions,
  ) {
    final recommendations = generateBudgetRecommendations(
      monthlyIncome,
      transactions,
    );

    final spendingPatterns = CategorizationService.analyzeSpendingPatterns(
        transactions);

    return recommendations.entries.map((entry) {
      final spent = spendingPatterns[entry.key] ?? 0.0;
      return Budget(
        category: entry.key,
        allocated: entry.value,
        spent: spent,
      );
    }).toList();
  }

  /// Generate AI-like insights based on spending
  static String generateInsight(
    double monthlyIncome,
    List<Transaction> transactions, {
    AppCurrency currency = AppCurrency.rwf,
  }) {
    if (transactions.isEmpty) {
      return 'Start tracking your expenses to get personalized insights!';
    }

    final spendingPatterns = CategorizationService.analyzeSpendingPatterns(
        transactions);
    final totalExpenses = spendingPatterns.values.fold(0.0, (a, b) => a + b);
    final savingsRate = ((monthlyIncome - totalExpenses) / monthlyIncome) * 100;

    // Find category with highest spending
    Category? highestCategory;
    double highestAmount = 0;
    for (var entry in spendingPatterns.entries) {
      if (entry.value > highestAmount) {
        highestAmount = entry.value;
        highestCategory = entry.key;
      }
    }

    if (highestCategory != null) {
      final percentage = (highestAmount / totalExpenses) * 100;
      
      if (percentage > 35) {
        return 'You\'re spending ${percentage.toStringAsFixed(0)}% on ${highestCategory.name}. Consider reducing by ${(highestAmount * 0.1).toStringAsFixed(0)} ${currency.symbol} to improve your savings rate.';
      }
    }

    if (savingsRate < 20) {
      return 'Your savings rate is ${savingsRate.toStringAsFixed(0)}%. Try to save at least 20% of your income for better financial health.';
    }

    return 'Great job! You\'re managing your finances well. Keep tracking to maintain good habits!';
  }
}