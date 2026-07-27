import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/balance_card.dart';
import '../widgets/stats_card.dart';
import '../widgets/transaction_item.dart';
import '../widgets/add_transaction_dialog.dart';
import '../widgets/expense_trend_chart.dart';
import '../widgets/cash_flow_chart.dart';
import '../widgets/spending_reason_chart.dart';
import '../widgets/personalized_header.dart';
import '../widgets/monthly_overview_card.dart';
import '../widgets/category_donut_chart.dart';
import '../widgets/financial_health_score.dart';
import '../widgets/savings_rate_card.dart';
import '../widgets/ai_tip_card.dart';
import '../widgets/top_spending_categories_widget.dart';
import '../providers/transaction_provider.dart';
import '../providers/goal_provider.dart';
import '../providers/income_provider.dart';
import '../models/transaction.dart';
import '../services/budget_recommendation_service.dart';
import '../providers/currency_provider.dart';
import 'transactions_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProvider, GoalProvider>(
      builder: (context, transactionProvider, goalProvider, child) {
        final balance = transactionProvider.balance;
        final recentTransactions = transactionProvider.getRecentTransactions(5);
        final accountBalances = transactionProvider.accountBalances;
        final income = transactionProvider.totalIncome;
        final expenses = transactionProvider.totalExpenses;
        // Consumption = spending WITHOUT money set aside for goals, so setting
        // money aside raises your savings rate instead of looking like spending.
        final consumption = transactionProvider.totalConsumption;
        final categorySpending = transactionProvider.getCategorySpending();

        // Show default message if no transactions
        if (transactionProvider.transactions.isEmpty) {
          return _buildEmptyState(context, transactionProvider, balance,
              income, expenses);
        }

        // Income used for health score / savings rate: prefer real tracked
        // income, fall back to the income target set in Settings.
        final monthlyTarget = context.watch<IncomeProvider>().monthlyIncome;
        final effectiveIncome = income > 0 ? income : monthlyTarget;
        final currency = context.watch<CurrencyProvider>().currency;
        final aiInsight = BudgetRecommendationService.generateInsight(
          effectiveIncome,
          transactionProvider.transactions,
          currency: currency,
        );

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Greeting
                const PersonalizedHeader(),

                // Balance (hero)
                BalanceCard(
                  balance: balance,
                  onAddIncome: () {
                    _showAddTransactionDialog(context, TransactionType.income);
                  },
                  onAddExpense: () {
                    _showAddTransactionDialog(context, TransactionType.expense);
                  },
                ),

                // Total / Reserved / Available (only when goals reserve money)
                if (goalProvider.totalReserved > 0) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _SpendableReservedCard(
                      total: balance,
                      reserved: goalProvider.totalReserved,
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // This Month — the headline analysis
                const MonthlyOverviewCard(),

                const SizedBox(height: 10),

                // Financial Health Score
                FinancialHealthScore(
                  income: effectiveIncome,
                  expenses: consumption,
                  goalsCompleted: goalProvider.goals
                      .where((g) => g.currentAmount >= g.targetAmount)
                      .length,
                  totalGoals: goalProvider.goals.length,
                ),

                // Savings Rate
                SavingsRateCard(
                  income: effectiveIncome,
                  expenses: consumption,
                  savings: effectiveIncome - consumption,
                  isUsingFallbackIncome: income == 0 && monthlyTarget > 0,
                ),

                const SizedBox(height: 16),

                // Spending by category (real donut for the month)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CategoryDonutChart(
                    transactions: transactionProvider.transactions,
                  ),
                ),

                const SizedBox(height: 16),

                // Top spending categories (list form)
                if (categorySpending.isNotEmpty)
                  TopSpendingCategoriesWidget(
                    categorySpending: categorySpending,
                    limit: 3,
                  ),

                if (categorySpending.isNotEmpty) const SizedBox(height: 16),

                // Accounts overview (Cash / MoMo / Bank)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _AccountsSummaryCard(
                    balances: accountBalances,
                    reserved: goalProvider.reservedByAccount,
                  ),
                ),

                const SizedBox(height: 16),

                // Why you spent — FinWise's differentiator, now a real chart
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SpendingReasonChart(
                    transactions: transactionProvider.transactions,
                  ),
                ),

                const SizedBox(height: 16),

                // Smart tip based on your spending
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AITipCard(tip: aiInsight),
                ),

                const SizedBox(height: 16),

                // Money in vs out by month — the "am I living within my
                // means?" chart.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CashFlowChart(
                    transactions: transactionProvider.transactions,
                  ),
                ),

                const SizedBox(height: 16),

                // Weekly spending trend (now with real axes)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ExpenseTrendChart(
                    transactions: transactionProvider.transactions,
                  ),
                ),

                const SizedBox(height: 20),

                // Recent transactions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent transactions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TransactionsScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'View all →',
                          style: TextStyle(color: AppTheme.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Swipe-to-delete and tap-to-edit, same as the History screen.
                // Both go through TransactionProvider, which is the single
                // source of truth — so removing one here updates the balance,
                // history, charts and accounts everywhere at once.
                ...recentTransactions.map((transaction) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TransactionItem(
                        transaction: transaction,
                        onEdit: () =>
                            _editTransaction(context, transaction),
                        onDelete: () {
                          Provider.of<TransactionProvider>(context,
                                  listen: false)
                              .removeTransaction(transaction.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Transaction deleted'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    )),

                const SizedBox(height: 100), // Space for FAB
              ],
            ),
          ),
        );
      },
    );
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
              children: const [
                Text(
                  'Hello',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Let's manage your money wisely",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
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
                      icon: Icons.trending_up,
                      label: 'Income',
                      value: income,
                      color: AppTheme.incomeColor,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: StatsCard(
                      icon: Icons.trending_down,
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
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: AppTheme.primaryColor,
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

  /// Edit an existing transaction from the dashboard. Saving updates it in
  /// place (same id), so the balance and every screen stay consistent.
  void _editTransaction(BuildContext context, Transaction transaction) {
    showDialog(
      context: context,
      builder: (dialogContext) => AddTransactionDialog(
        existingTransaction: transaction,
        onSave: (updated) {
          Provider.of<TransactionProvider>(context, listen: false)
              .updateTransaction(updated);
        },
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

class _SpendableReservedCard extends StatelessWidget {
  final double total;
  final double reserved;

  const _SpendableReservedCard({
    required this.total,
    required this.reserved,
  });

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _cell(
              icon: Icons.account_balance_outlined,
              color: AppTheme.textSecondary,
              label: 'Total',
              value: currency.formatCompact(total),
            ),
          ),
          _sep(),
          Expanded(
            child: _cell(
              icon: Icons.lock_outline,
              color: AppTheme.accentDark,
              label: 'Reserved',
              value: currency.formatCompact(reserved),
            ),
          ),
          _sep(),
          Expanded(
            child: _cell(
              icon: Icons.account_balance_wallet_outlined,
              color: AppTheme.primaryColor,
              label: 'Available',
              value: currency.formatCompact(total - reserved),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sep() => Container(
        width: 1,
        height: 34,
        color: Colors.grey.withValues(alpha: 0.2),
        margin: const EdgeInsets.symmetric(horizontal: 10),
      );

  Widget _cell({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _AccountsSummaryCard extends StatelessWidget {
  final Map<AccountType, double> balances;
  final Map<AccountType, double> reserved;

  const _AccountsSummaryCard({
    required this.balances,
    this.reserved = const {},
  });

  @override
  Widget build(BuildContext context) {
    final anyReserved = reserved.values.any((v) => v > 0);
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
            if (anyReserved)
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Text(
                  'Balance · reserved · available',
                  style: TextStyle(fontSize: 11, color: AppTheme.textLight),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                // One brand colour across all three accounts — the icon and
                // label distinguish them, not a different hue each.
                _AccountBalanceChip(
                  label: 'Cash',
                  icon: Icons.payments_outlined,
                  color: AppTheme.primaryColor,
                  amount: balances[AccountType.cash] ?? 0,
                  reserved: reserved[AccountType.cash] ?? 0,
                ),
                const SizedBox(width: 8),
                _AccountBalanceChip(
                  label: 'MoMo',
                  icon: Icons.phone_iphone,
                  color: AppTheme.primaryColor,
                  amount: balances[AccountType.mobileMoney] ?? 0,
                  reserved: reserved[AccountType.mobileMoney] ?? 0,
                ),
                const SizedBox(width: 8),
                _AccountBalanceChip(
                  label: 'Bank',
                  icon: Icons.account_balance,
                  color: AppTheme.primaryColor,
                  amount: balances[AccountType.bank] ?? 0,
                  reserved: reserved[AccountType.bank] ?? 0,
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
  final double reserved;

  const _AccountBalanceChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.amount,
    this.reserved = 0,
  });

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>();
    final available = amount - reserved;
    // Reserved money must actually exist in the account — flag it if the
    // balance has fallen below what's committed to goals.
    final underFunded = reserved > 0 && available < 0;
    final warn = AppTheme.accentDark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: underFunded
              ? Border.all(color: warn.withValues(alpha: 0.7))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              currency.formatCompact(amount),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (reserved > 0) ...[
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(Icons.lock_outline,
                      size: 10, color: AppTheme.textSecondary),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      currency.formatCompact(reserved),
                      style: const TextStyle(
                          fontSize: 10, color: AppTheme.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    underFunded
                        ? Icons.error_outline
                        : Icons.check_circle_outline,
                    size: 10,
                    color: underFunded ? warn : AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      underFunded
                          ? 'short ${currency.formatCompact(-available)}'
                          : currency.formatCompact(available),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: underFunded ? warn : AppTheme.primaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// The old text-only "why you spent" card and its pills were replaced by
// SpendingReasonChart (lib/widgets/spending_reason_chart.dart), which shows
// the same data as a proportional bar with amounts and percentages.

