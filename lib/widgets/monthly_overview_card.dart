import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/overview_period.dart';
import '../providers/transaction_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/goal_provider.dart';
import '../providers/income_provider.dart';
import '../providers/period_provider.dart';
import '../theme/app_theme.dart';
import 'period_picker.dart';
import '../l10n/l10n_helpers.dart';
import '../l10n/app_localizations.dart';

/// The dashboard's headline analysis: money in, money spent (consumption
/// only), the resulting savings rate, and how it compares to the optional
/// income target — for the period chosen in [PeriodProvider] (a month, a
/// year, the last N days, a custom range, or all time). The same period is
/// shown in History, so both screens always describe the same window.
///
/// Everything is computed from REAL transactions — nothing made up.
class MonthlyOverviewCard extends StatelessWidget {
  const MonthlyOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final currency = context.watch<CurrencyProvider>();
    final incomeProvider = context.watch<IncomeProvider>();
    final period = context.watch<PeriodProvider>().period;
    final l = context.l10n;

    final all = txProvider.transactions;
    final summary = PeriodSummary.of(all.where((t) => period.contains(t.date)));
    final moneyIn = summary.moneyIn;
    final spent = summary.spent;

    // Transactions are sorted newest first, so the oldest is last.
    final earliest = all.isEmpty ? null : all.last.date;
    // Income target scaled to the period's length (0 when not set).
    final target =
        incomeProvider.monthlyIncome * period.monthsSpanned(earliest: earliest);
    // Base for the savings rate: prefer real income in the period, fall back
    // to the target so the rate is still meaningful early in the period.
    final base = moneyIn > 0 ? moneyIn : target;
    final saved = base - spent;
    final savingsRate =
        base > 0 ? (saved / base * 100).clamp(-100.0, 100.0) : 0.0;
    // Net money put into goals during the period (reserves minus releases).
    // It isn't spending, but it isn't free to spend either, so it comes off
    // "safe to spend" and counts as saved.
    double setAside = 0;
    for (final g in context.watch<GoalProvider>().goals) {
      for (final c in g.contributions) {
        if (period.contains(c.date)) setAside += c.signedAmount;
      }
    }
    final safeToSpend =
        (target > 0 ? target : moneyIn) - spent - (setAside > 0 ? setAside : 0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
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
          const PeriodSelector(color: Colors.white, leadingIcon: Icons.insights),
          const SizedBox(height: 16),
          Row(
            children: [
              _stat(currency, l.moneyIn, moneyIn, Icons.south_west),
              _divider(),
              _stat(currency, l.spent, spent, Icons.north_east),
              _divider(),
              _stat(currency, l.left, summary.left,
                  Icons.account_balance_wallet_outlined),
            ],
          ),
          if (setAside > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.savings_outlined,
                    color: Colors.white.withValues(alpha: 0.9), size: 14),
                const SizedBox(width: 6),
                Text(
                  l.setAsideForGoals(currency.formatCompact(setAside)),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          if (base > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l.savingsRate,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
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
              _message(l, currency, savingsRate, safeToSpend, target, moneyIn,
                  period.isCurrent),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ] else
            Text(
              period.isCurrent ? l.noIncomeCurrent : l.noIncomePast,
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

  String _message(AppLocalizations l, CurrencyProvider currency, double rate,
      double safeToSpend, double target, double moneyIn, bool isCurrent) {
    final parts = <String>[];
    if (isCurrent) {
      if (safeToSpend > 0) {
        parts.add(l.safeToSpend(currency.formatCompact(safeToSpend)));
      } else if (safeToSpend < 0) {
        parts.add(l.overBy(currency.formatCompact(-safeToSpend)));
      }
    } else {
      // The period is over — report the outcome rather than advice.
      if (safeToSpend > 0) {
        parts.add(l.youKept(currency.formatCompact(safeToSpend)));
      } else if (safeToSpend < 0) {
        parts.add(l.overspentBy(currency.formatCompact(-safeToSpend)));
      }
    }
    if (target > 0 && moneyIn > 0) {
      final pct = (moneyIn / target * 100).clamp(0, 999).toStringAsFixed(0);
      parts.add(l.earnedPctOfIncome(pct));
    }
    if (parts.isEmpty) {
      return rate >= 20 ? l.greatPace : l.watchSpending;
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
