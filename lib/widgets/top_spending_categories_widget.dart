import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/transaction.dart' as models;
import 'package:intl/intl.dart';

class TopSpendingCategoriesWidget extends StatelessWidget {
  final Map<models.Category, double> categorySpending;
  final int limit;

  const TopSpendingCategoriesWidget({
    super.key,
    required this.categorySpending,
    this.limit = 3,
  });

  List<MapEntry<models.Category, double>> get topCategories {
    final sorted = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (topCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    final formatter = NumberFormat('#,###');
    final total = categorySpending.values.fold(0.0, (a, b) => a + b);

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
              const Text(
                'Top Spending Categories',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                'This Month',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...topCategories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value.key;
            final amount = entry.value.value;
            final percentage = total > 0 ? (amount / total * 100) : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  // Rank indicator
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _getRankColor(index).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getRankColor(index),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Category icon
                  Icon(
                    category.icon,
                    size: 24,
                    color: category.color,
                  ),
                  const SizedBox(width: 12),
                  // Category name and progress
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              category.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              '${formatter.format(amount)} RWF',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            minHeight: 6,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              category.color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${percentage.toStringAsFixed(1)}% of total spending',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber; // Gold for #1
      case 1:
        return Colors.grey[600]!; // Silver for #2
      case 2:
        return Colors.brown[300]!; // Bronze for #3
      default:
        return AppTheme.primaryColor;
    }
  }
}
