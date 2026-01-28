import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/balance_card.dart';
import '../widgets/stats_card.dart';
import '../widgets/ai_tip_card.dart';
import '../widgets/transaction_item.dart';
import '../widgets/add_transaction_dialog.dart';
import '../widgets/expense_trend_chart.dart';
import '../widgets/personalized_header.dart';
import '../widgets/savings_rate_card.dart';
import '../widgets/financial_health_score.dart';
import '../widgets/top_spending_categories_widget.dart';
import '../widgets/loading_skeleton.dart';
import '../providers/transaction_provider.dart';
import '../providers/goal_provider.dart';
import '../models/transaction.dart';
import '../services/budget_recommendation_service.dart';
import 'transactions_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProvider, GoalProvider>(
      builder: (context, transactionProvider, goalProvider, child) {
        final balance = transactionProvider.balance;
        final income = transactionProvider.totalIncome;
        final expenses = transactionProvider.totalExpenses;
        final savings = income - expenses;
        final recentTransactions = transactionProvider.getRecentTransactions(3);
        final categorySpending = transactionProvider.getCategorySpending();
        final accountBalances = transactionProvider.accountBalances;
        final spendingByReason = transactionProvider.spendingByReason;
        
        // Show default message if no transactions
        if (transactionProvider.transactions.isEmpty) {
          return _buildEmptyState(context, transactionProvider, balance, income, expenses);
        }

        return FutureBuilder<double>(
          future: _getUserIncome(),
          builder: (context, incomeSnapshot) {
            if (incomeSnapshot.connectionState == ConnectionState.waiting) {
              return const DashboardSkeleton();
            }
            
            final monthlyIncome = incomeSnapshot.data ?? income;
            final aiInsight = BudgetRecommendationService.generateInsight(
              monthlyIncome,
              transactionProvider.transactions,
            );

            return SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Personalized Header
                    const PersonalizedHeader(),

                    // Balance Card
                    BalanceCard(
                      balance: balance,
                      onAddIncome: () {
                        _showAddTransactionDialog(context, TransactionType.income);
                      },
                      onAddExpense: () {
                        _showAddTransactionDialog(context, TransactionType.expense);
                      },
                    ),

                    // Stats Grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: StatsCard(
                              icon: '📈',
                              label: 'Income',
                              value: income,
                              color: AppTheme.incomeColor,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: StatsCard(
                              icon: '📉',
                              label: 'Expenses',
                              value: expenses,
                              color: AppTheme.expenseColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Financial Health Score
                    FinancialHealthScore(
                      income: monthlyIncome > 0 ? monthlyIncome : income,
                      expenses: expenses,
                      goalsCompleted: goalProvider.goals.where((g) => g.currentAmount >= g.targetAmount).length,
                      totalGoals: goalProvider.goals.length,
                    ),

                    // Savings Rate Card
                    SavingsRateCard(
                      // For savings rate, use actual tracked income from transactions
                      // so this card always reflects real money flowing through the app.
                      income: income,
                      expenses: expenses,
                      savings: savings,
                    ),

                    const SizedBox(height: 10),

                    // Accounts Summary (Cash / MoMo / Bank)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _AccountsSummaryCard(balances: accountBalances),
                    ),

                    const SizedBox(height: 10),

                    // Top Spending Categories
                    if (categorySpending.isNotEmpty)
                      TopSpendingCategoriesWidget(
                        categorySpending: categorySpending,
                        limit: 3,
                      ),

                    const SizedBox(height: 20),

                    // Spending Reason Summary
                    if (spendingByReason.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _SpendingReasonSummaryCard(
                          totals: spendingByReason,
                        ),
                      ),

                    const SizedBox(height: 20),

                    // AI Tip (Dynamic based on spending patterns)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: AITipCard(
                        tip: aiInsight,
                      ),
                    ),

              const SizedBox(height: 20),

                    // Expense Trend Chart
                    if (recentTransactions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ExpenseTrendChart(
                          transactions: transactionProvider.transactions,
                        ),
                      ),

                    if (recentTransactions.isNotEmpty) const SizedBox(height: 20),

                    // Categories Section
                    Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Category Pills
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _CategoryPill(category: Category.food),
                    _CategoryPill(category: Category.transport),
                    _CategoryPill(category: Category.entertainment),
                    _CategoryPill(category: Category.utilities),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Recent Transactions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to transactions screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TransactionsScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'View All →',
                        style: TextStyle(color: AppTheme.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Transaction List
              if (recentTransactions.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No transactions yet. Tap + to add one!',
                    style: TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...recentTransactions.map((transaction) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TransactionItem(transaction: transaction),
                    )),

                    const SizedBox(height: 100), // Space for FAB
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

  Widget _buildEmptyState(BuildContext context, TransactionProvider provider,
      double balance, double income, double expenses) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '👋 Hello, User!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Let's manage your money wisely",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Balance Card
            BalanceCard(
              balance: balance,
              onAddIncome: () {
                _showAddTransactionDialog(context, TransactionType.income);
              },
              onAddExpense: () {
                _showAddTransactionDialog(context, TransactionType.expense);
              },
            ),

            // Stats Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      icon: '📈',
                      label: 'Income',
                      value: income,
                      color: AppTheme.incomeColor,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: StatsCard(
                      icon: '📉',
                      label: 'Expenses',
                      value: expenses,
                      color: AppTheme.expenseColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Empty State Message
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  const Text(
                    '💰',
                    style: TextStyle(fontSize: 64),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Start Tracking Your Finances',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tap the + button to add your first transaction',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context, TransactionType type) {
    showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(
        initialType: type,
        onSave: (transaction) {
          Provider.of<TransactionProvider>(context, listen: false)
              .addTransaction(transaction);
        },
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final Category category;

  const _CategoryPill({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${category.emoji} ${category.name}',
        style: const TextStyle(
          fontSize: 13,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}

class _AccountsSummaryCard extends StatelessWidget {
  final Map<AccountType, double> balances;

  const _AccountsSummaryCard({required this.balances});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Accounts overview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _AccountBalanceChip(
                  label: 'Cash',
                  icon: Icons.payments_outlined,
                  color: Colors.orangeAccent,
                  amount: balances[AccountType.cash] ?? 0,
                ),
                const SizedBox(width: 8),
                _AccountBalanceChip(
                  label: 'MoMo',
                  icon: Icons.phone_iphone,
                  color: AppTheme.primaryColor,
                  amount: balances[AccountType.mobileMoney] ?? 0,
                ),
                const SizedBox(width: 8),
                _AccountBalanceChip(
                  label: 'Bank',
                  icon: Icons.account_balance,
                  color: Colors.teal,
                  amount: balances[AccountType.bank] ?? 0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountBalanceChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final double amount;

  const _AccountBalanceChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'RWF ${amount.toStringAsFixed(0)}',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpendingReasonSummaryCard extends StatelessWidget {
  final Map<SpendingReason, double> totals;

  const _SpendingReasonSummaryCard({required this.totals});

  @override
  Widget build(BuildContext context) {
    final totalAmount =
        totals.values.fold<double>(0.0, (sum, v) => sum + v).clamp(0.0, double.infinity);
    if (totalAmount == 0) return const SizedBox.shrink();

    double pct(SpendingReason r) =>
        ((totals[r] ?? 0) / totalAmount * 100).clamp(0, 100);

    String formatPct(double v) => v.toStringAsFixed(0);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Why you spent this month',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Most of your expenses are ${_dominantReasonLabel()}',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ReasonPill(
                  label: 'Necessity',
                  emoji: '🧾',
                  percent: formatPct(pct(SpendingReason.necessity)),
                ),
                _ReasonPill(
                  label: 'Business',
                  emoji: '💼',
                  percent: formatPct(pct(SpendingReason.business)),
                ),
                _ReasonPill(
                  label: 'Enjoyment',
                  emoji: '🎉',
                  percent: formatPct(pct(SpendingReason.enjoyment)),
                ),
                _ReasonPill(
                  label: 'Emergency',
                  emoji: '🚨',
                  percent: formatPct(pct(SpendingReason.emergency)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _dominantReasonLabel() {
    if (totals.isEmpty) return 'mixed';
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.first.key;
    switch (top) {
      case SpendingReason.necessity:
        return 'on necessities';
      case SpendingReason.business:
        return 'for business';
      case SpendingReason.enjoyment:
        return 'for enjoyment';
      case SpendingReason.emergency:
        return 'on emergencies';
    }
  }
}

class _ReasonPill extends StatelessWidget {
  final String label;
  final String emoji;
  final String percent;

  const _ReasonPill({
    required this.label,
    required this.emoji,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji),
          const SizedBox(width: 6),
          Text(
            '$label · $percent%',
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
