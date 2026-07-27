import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';
import '../providers/currency_provider.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';

/// Donut chart of this month's spending by category — the "where your money
/// goes" visual. Uses REAL expense transactions for the current month,
/// excluding income and savings (savings is money set aside, not spending).
class CategoryDonutChart extends StatelessWidget {
  final List<Transaction> transactions;

  const CategoryDonutChart({super.key, required this.transactions});

  // Distinct, readable palette assigned by rank (brighter than the pastel
  // category colors, so slices are easy to tell apart).
  static const List<Color> _palette = [
    Color(0xFF2E9E5B), // green (brand)
    Color(0xFF2196F3), // blue
    Color(0xFFFF9800), // orange
    Color(0xFFE91E63), // pink
    Color(0xFF9C27B0), // purple
    Color(0xFF9E9E9E), // grey ("Other")
  ];

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>();
    final now = DateTime.now();

    final Map<Category, double> spend = {};
    for (final t in transactions) {
      if (t.type != TransactionType.expense) continue;
      if (t.category == Category.savings) continue;
      if (t.date.year != now.year || t.date.month != now.month) continue;
      spend[t.category] = (spend[t.category] ?? 0) + t.amount;
    }
    final total = spend.values.fold<double>(0, (s, v) => s + v);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const Text(
            'Spending by category · This month',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (total <= 0)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No spending recorded this month yet.',
                  style: TextStyle(color: AppTheme.textLight),
                ),
              ),
            )
          else
            _buildChart(context, currency, spend, total),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context, CurrencyProvider currency,
      Map<Category, double> spend, double total) {
    final entries = spend.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(5).toList();
    final otherTotal = entries.skip(5).fold<double>(0, (s, e) => s + e.value);

    // Build slice descriptors (label, amount, color).
    final slices = <_Slice>[];
    for (var i = 0; i < top.length; i++) {
      slices.add(_Slice(
        label: top[i].key.name,
        icon: top[i].key.icon,
        amount: top[i].value,
        color: _palette[i % _palette.length],
      ));
    }
    if (otherTotal > 0) {
      slices.add(_Slice(
        label: 'Other',
        icon: Icons.more_horiz,
        amount: otherTotal,
        color: _palette.last,
      ));
    }

    return Row(
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 42,
                  sections: slices.map((s) {
                    return PieChartSectionData(
                      value: s.amount,
                      color: s.color,
                      radius: 22,
                      showTitle: false,
                    );
                  }).toList(),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textLight,
                    ),
                  ),
                  Text(
                    currency.formatCompact(total),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: slices.map((s) {
              final pct = (s.amount / total * 100).toStringAsFixed(0);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: s.color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(s.icon, size: 13, color: AppTheme.textSecondary),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        s.label,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '$pct%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _Slice {
  final String label;
  final IconData icon;
  final double amount;
  final Color color;
  _Slice({
    required this.label,
    required this.icon,
    required this.amount,
    required this.color,
  });
}
