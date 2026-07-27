import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/currency_provider.dart';
import '../theme/app_theme.dart';

/// Income vs expenses, month by month — the single most useful chart in a
/// money app, because it answers "am I living within my means?" at a glance.
///
/// Savings transfers are excluded from expenses: setting money aside isn't
/// consumption, so counting it would make every saving month look like
/// overspending.
class CashFlowChart extends StatelessWidget {
  final List<Transaction> transactions;
  final int monthsToShow;

  const CashFlowChart({
    super.key,
    required this.transactions,
    this.monthsToShow = 6,
  });

  static const List<String> _monthAbbr = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>();
    final months = _monthlyData();
    final hasData = months.any((m) => m.income > 0 || m.expense > 0);

    if (!hasData) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: _card(),
        child: const SizedBox(
          height: 120,
          child: Center(
            child: Text(
              'Not enough data yet for a cash flow view',
              style: TextStyle(color: AppTheme.textLight),
            ),
          ),
        ),
      );
    }

    final maxValue = months
        .map((m) => m.income > m.expense ? m.income : m.expense)
        .reduce((a, b) => a > b ? a : b);
    final maxY = maxValue * 1.2;

    final current = months.last;
    final net = current.income - current.expense;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Money in vs out',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Row(
                children: [
                  _legendDot(AppTheme.primaryColor, 'In'),
                  const SizedBox(width: 12),
                  _legendDot(AppTheme.accentDark, 'Out'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            net >= 0
                ? 'This month you kept ${currency.formatCompact(net)}'
                : 'This month you spent ${currency.formatCompact(-net)} more than you earned',
            style: TextStyle(
              fontSize: 12,
              color: net >= 0 ? AppTheme.primaryColor : AppTheme.expenseColor,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                alignment: BarChartAlignment.spaceAround,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.grey.withValues(alpha: 0.15),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 46,
                      interval: maxY / 4,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text(
                            _shortMoney(value),
                            style: const TextStyle(
                                fontSize: 10, color: AppTheme.textLight),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= months.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            months[i].label,
                            style: const TextStyle(
                                fontSize: 10, color: AppTheme.textLight),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIdx, rod, rodIdx) {
                      final m = months[group.x.toInt()];
                      final isIncome = rodIdx == 0;
                      return BarTooltipItem(
                        '${m.label}\n${isIncome ? 'In' : 'Out'}: ${currency.formatCompact(rod.toY)}',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < months.length; i++)
                    BarChartGroupData(
                      x: i,
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(
                          toY: months[i].income,
                          color: AppTheme.primaryColor,
                          width: 9,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(3)),
                        ),
                        BarChartRodData(
                          toY: months[i].expense,
                          color: AppTheme.accentDark,
                          width: 9,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(3)),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration:
              BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }

  List<_MonthPoint> _monthlyData() {
    final now = DateTime.now();
    final points = <_MonthPoint>[];

    for (int i = monthsToShow - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      double income = 0, expense = 0;

      for (final t in transactions) {
        if (t.date.year != month.year || t.date.month != month.month) continue;
        if (t.type == TransactionType.income) {
          income += t.amount;
        } else if (t.category != Category.savings) {
          expense += t.amount;
        }
      }

      points.add(_MonthPoint(
        label: _monthAbbr[month.month - 1],
        income: income,
        expense: expense,
      ));
    }
    return points;
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

  static String _shortMoney(double v) {
    if (v >= 1000000) {
      final m = v / 1000000;
      return '${m.toStringAsFixed(m >= 10 ? 0 : 1)}M';
    }
    if (v >= 1000) {
      final k = v / 1000;
      return '${k.toStringAsFixed(k >= 10 ? 0 : 1)}K';
    }
    return v.toStringAsFixed(0);
  }
}

class _MonthPoint {
  final String label;
  final double income;
  final double expense;
  const _MonthPoint({
    required this.label,
    required this.income,
    required this.expense,
  });
}
