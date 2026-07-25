import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/income_provider.dart';
import '../theme/app_theme.dart';

/// The dashboard's headline analysis: this calendar month's money in, money
/// spent (consumption only), money set aside (savings), the resulting savings
/// rate, and how it compares to the optional income target.
///
/// Everything is computed from REAL transactions — nothing made up. Savings
/// (Category.other's sibling `Category.savings`) is treated as "set aside",
/// not "spent", so putting money toward a goal doesn't look like consumption.
class MonthlyOverviewCard extends StatelessWidget {
  const MonthlyOverviewCard({super.key});

  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final currency = context.watch<CurrencyProvider>();
    final incomeProvider = context.watch<IncomeProvider>();

    final now = DateTime.now();
    bool isThisMonth(DateTime d) => d.year == now.year && d.month == now.month;

    double moneyIn = 0, spent = 0;
    for (final t in txProvider.transactions) {
      if (!isThisMonth(t.date)) continue;
      if (t.type == TransactionType.income) {
        moneyIn += t.amount;
      } else if (t.category == Category.savings) {
        // Legacy "set aside" transactions — ignore in the spending view.
        continue;
      } else {
        spent += t.amount;
      }
    }

    final left = moneyIn - spent;
    final target = incomeProvider.monthlyIncome; // 0 when not set
    // Base for the savings rate: prefer real income this month, fall back to
    // the target so the rate is still meaningful early in the month.
    final base = moneyIn > 0 ? moneyIn : target;
    final saved = base - spent;
    final savingsRate =
        base > 0 ? (saved / base * 100).clamp(-100.0, 100.0) : 0.0;
    final safeToSpend = (target > 0 ? target : moneyIn) - spent;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                'This month · ${_months[now.month - 1]}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _stat(currency, 'Money in', moneyIn, Icons.south_west),
              _divider(),
              _stat(currency, 'Spent', spent, Icons.north_east),
              _divider(),
              _stat(currency, 'Left', left,
                  Icons.account_balance_wallet_outlined),
            ],
          ),
          const SizedBox(height: 16),
          if (base > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Savings rate',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                Text(
                  '${savingsRate.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (savingsRate.clamp(0, 100)) / 100,
                minHeight: 7,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _message(currency, savingsRate, safeToSpend, target, moneyIn),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ] else
            Text(
              'Add some income this month, or set an income target in Settings, to see your savings rate.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 12,
                height: 1.4,
              ),
            ),
        ],
      ),
    );
  }

  String _message(CurrencyProvider currency, double rate, double safeToSpend,
      double target, double moneyIn) {
    final parts = <String>[];
    if (safeToSpend > 0) {
      parts.add('Safe to spend: ${currency.formatCompact(safeToSpend)}');
    } else if (safeToSpend < 0) {
      parts.add('You are over by ${currency.formatCompact(-safeToSpend)}');
    }
    if (target > 0 && moneyIn > 0) {
      final pct = (moneyIn / target * 100).clamp(0, 999).toStringAsFixed(0);
      parts.add('earned $pct% of your usual income');
    }
    if (parts.isEmpty) {
      return rate >= 20
          ? 'Great pace — keep it up.'
          : 'Watch your spending to save more.';
    }
    return '${parts.join(' · ')}.';
  }

  Widget _divider() => Container(
        width: 1,
        height: 38,
        color: Colors.white.withValues(alpha: 0.25),
        margin: const EdgeInsets.symmetric(horizontal: 10),
      );

  Widget _stat(
      CurrencyProvider currency, String label, double value, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 13),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            currency.formatCompact(value),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
