import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/currency_provider.dart';
import '../l10n/l10n_helpers.dart';

class SavingsRateCard extends StatelessWidget {
  final double income;
  final double expenses;
  final double savings;
  final bool isUsingFallbackIncome; // true if using onboarding income (no transaction income)

  const SavingsRateCard({
    super.key,
    required this.income,
    required this.expenses,
    required this.savings,
    this.isUsingFallbackIncome = false,
  });

  double get savingsRate {
    if (income == 0) return 0.0;
    return ((income - expenses) / income) * 100;
  }

  String savingsRateText(BuildContext context) {
    if (income == 0) return context.l10n.notAvailable;
    return '${savingsRate.toStringAsFixed(1)}%';
  }

  Color get savingsRateColor {
    if (savingsRate >= 20) return AppTheme.incomeColor; // Green - Excellent
    if (savingsRate >= 10) return Colors.orange; // Orange - Good
    if (savingsRate >= 0) return Colors.amber; // Amber - Fair
    return AppTheme.expenseColor; // Red - Negative
  }

  String savingsRateLabel(BuildContext context) {
    final l = context.l10n;
    if (savingsRate >= 20) return l.healthExcellent;
    if (savingsRate >= 10) return l.srGood;
    if (savingsRate >= 0) return l.healthFair;
    return l.srOverspending;
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.savingsRateTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: savingsRateColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  savingsRateText(context),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: savingsRateColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isUsingFallbackIncome
              ? context.l10n.usingProfileIncome
              : context.l10n.basedOnTracked,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            savingsRateLabel(context),
            style: TextStyle(
              fontSize: 14,
              color: savingsRateColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: savingsRate >= 0 ? (savingsRate / 100).clamp(0.0, 1.0) : 0,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(savingsRateColor),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatItem(
                label: context.l10n.income,
                value: currencyProvider.formatCompact(income),
                color: AppTheme.incomeColor,
              ),
              _StatItem(
                label: context.l10n.expenses,
                value: currencyProvider.formatCompact(expenses),
                color: AppTheme.expenseColor,
              ),
              _StatItem(
                label: context.l10n.saved,
                value: currencyProvider.formatCompact(savings),
                color: savingsRateColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
