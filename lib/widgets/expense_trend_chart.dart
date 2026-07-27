import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/currency_provider.dart';
import '../theme/app_theme.dart';

/// Weekly spending trend for the last 4 weeks.
///
/// Previously this drew a line with NO y-axis labels, so you could see a shape
/// but not the amounts — a trend without numbers isn't analysis. It now shows
/// real money on the y-axis, real dates on the x-axis, and an average line for
/// context. Savings ("set aside") is excluded so it reflects consumption only.
class ExpenseTrendChart extends StatelessWidget {
  final List<Transaction> transactions;

  const ExpenseTrendChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>();
    final weeks = _weeklyData();

    if (weeks.every((w) => w.total == 0)) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: _card(),
        child: const SizedBox(
          height: 140,
          child: Center(
            child: Text(
              'No spending recorded in the last 4 weeks',
              style: TextStyle(color: AppTheme.textLight),
            ),
          ),
        ),
      );
    }

    final maxValue = weeks.map((w) => w.total).reduce((a, b) => a > b ? a : b);
    final average = weeks.fold<double>(0, (s, w) => s + w.total) / weeks.length;
    // Round the top of the axis up so labels land on clean numbers.
    final maxY = _niceCeiling(maxValue * 1.15);

    final latest = weeks.last.total;
    final previous = weeks[weeks.length - 2].total;
    final changePct = previous > 0
        ? ((latest - previous) / previous * 100)
        : (latest > 0 ? 100.0 : 0.0);
    final spentMore = latest > previous;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Spending trend · Last 4 weeks',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            previous > 0
                ? 'This week you spent ${changePct.abs().toStringAsFixed(0)}% ${spentMore ? 'more' : 'less'} than last week'
                : 'Average ${currency.formatCompact(average)} per week',
            style: TextStyle(
              fontSize: 12,
              color: spentMore ? AppTheme.accentDark : AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 190,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.grey.withValues(alpha: 0.15),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  // Y AXIS — actual money, so the chart can be read.
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
                              fontSize: 10,
                              color: AppTheme.textLight,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        );
                      },
                    ),
                  ),
                  // X AXIS — real dates instead of meaningless W1..W4.
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= weeks.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            weeks[i].label,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textLight,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                // Dashed average line for context.
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: average,
                      color: AppTheme.textLight.withValues(alpha: 0.6),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppTheme.textLight,
                        ),
                        labelResolver: (_) => 'avg',
                      ),
                    ),
                  ],
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots.map((s) {
                      return LineTooltipItem(
                        '${weeks[s.x.toInt()].label}\n${currency.formatCompact(s.y)}',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (var i = 0; i < weeks.length; i++)
                        FlSpot(i.toDouble(), weeks[i].total),
                    ],
                    isCurved: true,
                    curveSmoothness: 0.25,
                    color: AppTheme.primaryColor,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, ___) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2.5,
                        strokeColor: AppTheme.primaryColor,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.primaryColor.withValues(alpha: 0.22),
                          AppTheme.primaryColor.withValues(alpha: 0.01),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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

  /// Four clean, non-overlapping 7-day windows ending today, labelled with the
  /// date each window starts. Savings transfers are excluded.
  List<_WeekPoint> _weeklyData() {
    final now = DateTime.now();
    final fmt = DateFormat('MMM d');
    final points = <_WeekPoint>[];

    for (int i = 3; i >= 0; i--) {
      final start = now.subtract(Duration(days: (i + 1) * 7));
      final end = now.subtract(Duration(days: i * 7));

      final total = transactions
          .where((t) =>
              t.type == TransactionType.expense &&
              t.category != Category.savings &&
              t.date.isAfter(start) &&
              !t.date.isAfter(end))
          .fold(0.0, (sum, t) => sum + t.amount);

      points.add(_WeekPoint(label: fmt.format(start), total: total));
    }
    return points;
  }

  /// Compact axis labels: 1.2M, 450K, 900.
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

  /// Round up to a readable axis maximum so gridlines sit on tidy values.
  static double _niceCeiling(double v) {
    if (v <= 0) return 100;
    final magnitude = 1.0 * _pow10((v).floor().toString().length - 1);
    final step = magnitude / 2;
    return (v / step).ceil() * step;
  }

  static int _pow10(int exp) {
    var r = 1;
    for (var i = 0; i < exp; i++) {
      r *= 10;
    }
    return r;
  }
}

class _WeekPoint {
  final String label;
  final double total;
  const _WeekPoint({required this.label, required this.total});
}
