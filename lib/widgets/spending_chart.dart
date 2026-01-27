import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class SpendingChart extends StatelessWidget {
  final Map<Category, double> categorySpending;

  const SpendingChart({super.key, required this.categorySpending});

  @override
  Widget build(BuildContext context) {
    if (categorySpending.isEmpty) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: Text(
            'No spending data to display',
            style: TextStyle(color: AppTheme.textLight),
          ),
        ),
      );
    }

    final entries = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
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
            'Spending by Category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: _buildPieChartSections(entries),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...entries.take(5).map((entry) => _LegendItem(
                category: entry.key,
                amount: entry.value,
                percentage: (entry.value / categorySpending.values.fold(0.0, (a, b) => a + b)) * 100,
              )),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
      List<MapEntry<Category, double>> entries) {
    final total = entries.fold(0.0, (sum, entry) => sum + entry.value);
    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.accentColor,
      AppTheme.incomeColor,
      AppTheme.expenseColor,
      Colors.purple,
      Colors.orange,
      Colors.pink,
    ];

    return entries.asMap().entries.map((entry) {
      final index = entry.key;
      final categoryEntry = entry.value;
      final percentage = (categoryEntry.value / total) * 100;

      return PieChartSectionData(
        value: categoryEntry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        color: colors[index % colors.length],
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}

class _LegendItem extends StatelessWidget {
  final Category category;
  final double amount;
  final double percentage;

  const _LegendItem({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: category.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            category.emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              category.name,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Text(
            '${formatter.format(amount)} RWF',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
