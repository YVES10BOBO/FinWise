import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/budget.dart';
import '../providers/transaction_provider.dart';
import '../services/budget_recommendation_service.dart';
import '../services/categorization_service.dart';
import '../widgets/spending_chart.dart';
import '../providers/currency_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<double>(
          future: _getUserIncome(),
          builder: (context, incomeSnapshot) {
            if (incomeSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Categories'),
                ),
                body: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            final monthlyIncome = incomeSnapshot.data ?? 0.0;
            
            // Calculate real budgets from transactions
            final spendingPatterns = CategorizationService.analyzeSpendingPatterns(
              provider.transactions,
            );
            
            final budgetRecommendations = BudgetRecommendationService
                .getBudgetRecommendations(
              monthlyIncome > 0 ? monthlyIncome : 300000,
              provider.transactions,
            );

            return Scaffold(
              appBar: AppBar(
                title: const Text('Categories'),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Row(
                            children: const [
                              Icon(Icons.category_outlined,
                                  size: 22, color: AppTheme.primaryColor),
                              SizedBox(width: 8),
                              Text(
                                'Spending Categories',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'FinWise groups your expenses into simple categories so you can quickly see where your money goes.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Budgets here use your profile income from onboarding plus your real spending from transactions.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Spending Chart
                    if (spendingPatterns.isNotEmpty)
                      SpendingChart(categorySpending: spendingPatterns),
                    if (spendingPatterns.isNotEmpty) const SizedBox(height: 20),
                    // Budget Cards
                    ...budgetRecommendations.map((budget) => _CategoryCard(budget: budget)),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFE8F5E9), Color(0xFFE3F2FD)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.lightbulb_outline,
                                  size: 20, color: AppTheme.primaryColor),
                              SizedBox(width: 10),
                              Text(
                                'Category insight',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            BudgetRecommendationService.generateInsight(
                              monthlyIncome > 0 ? monthlyIncome : 300000,
                              provider.transactions,
                              currency: context.watch<CurrencyProvider>().currency,
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<double> _getUserIncome() async {
    final prefs = await SharedPreferences.getInstance();
    // Backward compatible: older builds may have saved `income`, newer onboarding uses `user_income`.
    final incomeStr = prefs.getString('user_income') ?? prefs.getString('income');
    if (incomeStr == null) return 0.0;

    final rawIncome = double.tryParse(incomeStr.trim()) ?? 0.0;
    if (rawIncome <= 0) return 0.0;

    // Convert to monthly income for consistent analysis across the app.
    final freq = prefs.getString('income_frequency') ?? 'Monthly';
    switch (freq) {
      case 'Daily':
        return rawIncome * 30;
      case 'Weekly':
        return rawIncome * 4.345; // average weeks per month
      case 'Yearly':
        return rawIncome / 12;
      case 'Monthly':
      default:
        return rawIncome;
    }
  }
}

class _CategoryCard extends StatelessWidget {
  final Budget budget;

  const _CategoryCard({required this.budget});

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();
    final percentage = budget.percentage.clamp(0.0, 100.0);
    final isOver = budget.isOverBudget;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                budget.category.icon,
                size: 26,
                color: budget.category.color,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget.category.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${currencyProvider.formatCompact(budget.spent)} / ${currencyProvider.formatCompact(budget.allocated)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isOver ? AppTheme.expenseColor : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isOver ? AppTheme.expenseColor : AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                isOver ? AppTheme.expenseColor : AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
