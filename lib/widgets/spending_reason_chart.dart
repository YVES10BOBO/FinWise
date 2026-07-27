import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/currency_provider.dart';
import '../theme/app_theme.dart';

/// Spending broken down by WHY money was spent — necessity, business,
/// enjoyment, emergency.
///
/// This is FinWise's differentiator. Mainstream apps can tell you that you
/// spent 30% on food; almost none can tell you what share of your money went
/// on things you actually needed. That's the more actionable question when
/// someone is trying to cut back.
class SpendingReasonChart extends StatelessWidget {
  final List<Transaction> transactions;

  const SpendingReasonChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>();
    final now = DateTime.now();

    // This month's expenses that have a reason recorded (savings excluded).
    final totals = <SpendingReason, double>{};
    double withReason = 0;
    double withoutReason = 0;

    for (final t in transactions) {
      if (t.type != TransactionType.expense) continue;
      if (t.category == Category.savings) continue;
      if (t.date.year != now.year || t.date.month != now.month) continue;

      if (t.reason != null) {
        totals[t.reason!] = (totals[t.reason!] ?? 0) + t.amount;
        withReason += t.amount;
      } else {
        withoutReason += t.amount;
      }
    }

    if (withReason <= 0) {
      // Nothing tagged yet — explain the value instead of showing an empty box.
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: _card(),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.psychology_outlined,
                  size: 22, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Why you spend',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tag a few expenses as necessity, enjoyment, business or '
                    'emergency to see what share of your money is essential.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Ordered so the bar always reads necessity → emergency.
    const order = [
      SpendingReason.necessity,
      SpendingReason.business,
      SpendingReason.enjoyment,
      SpendingReason.emergency,
    ];

    final necessityShare =
        ((totals[SpendingReason.necessity] ?? 0) / withReason * 100);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Why you spent · This month',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${necessityShare.toStringAsFixed(0)}% of your spending was on necessities',
            style: const TextStyle(
                fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),

          // Single stacked bar — compact and instantly readable.
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 16,
              child: Row(
                children: [
                  for (final r in order)
                    if ((totals[r] ?? 0) > 0)
                      Expanded(
                        flex: ((totals[r]! / withReason) * 1000).round(),
                        child: Container(color: _color(r)),
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Breakdown rows
          for (final r in order)
            if ((totals[r] ?? 0) > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _color(r),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _label(r),
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.textPrimary),
                      ),
                    ),
                    Text(
                      currency.formatCompact(totals[r]!),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 38,
                      child: Text(
                        '${(totals[r]! / withReason * 100).toStringAsFixed(0)}%',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),

          if (withoutReason > 0) ...[
            const Divider(height: 18),
            Text(
              '${currency.formatCompact(withoutReason)} not tagged with a reason',
              style: TextStyle(fontSize: 11, color: AppTheme.textLight),
            ),
          ],
        ],
      ),
    );
  }

  // Palette stays within the brand: teal for essential, amber for
  // discretionary, red for emergency.
  Color _color(SpendingReason r) {
    switch (r) {
      case SpendingReason.necessity:
        return AppTheme.primaryColor;
      case SpendingReason.business:
        return AppTheme.secondaryColor;
      case SpendingReason.enjoyment:
        return AppTheme.accentColor;
      case SpendingReason.emergency:
        return AppTheme.expenseColor;
    }
  }

  String _label(SpendingReason r) {
    switch (r) {
      case SpendingReason.necessity:
        return 'Necessity';
      case SpendingReason.business:
        return 'Business';
      case SpendingReason.enjoyment:
        return 'Enjoyment';
      case SpendingReason.emergency:
        return 'Emergency';
    }
  }

  BoxDecoration _card() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      );
}
