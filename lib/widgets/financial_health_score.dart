import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FinancialHealthScore extends StatelessWidget {
  final double income;
  final double expenses;
  final int goalsCompleted;
  final int totalGoals;

  const FinancialHealthScore({
    super.key,
    required this.income,
    required this.expenses,
    required this.goalsCompleted,
    required this.totalGoals,
  });

  double get savingsRate {
    if (income == 0) return 0.0;
    return ((income - expenses) / income) * 100;
  }

  int get healthScore {
    int score = 0;
    
    // Savings rate (0-40 points)
    if (savingsRate >= 20) score += 40;
    else if (savingsRate >= 15) score += 35;
    else if (savingsRate >= 10) score += 30;
    else if (savingsRate >= 5) score += 20;
    else if (savingsRate >= 0) score += 10;
    else score += 0; // Negative savings
    
    // Spending control (0-30 points)
    if (expenses <= income * 0.7) score += 30; // Spending 70% or less
    else if (expenses <= income * 0.8) score += 25;
    else if (expenses <= income * 0.9) score += 20;
    else if (expenses <= income) score += 10;
    else score += 0; // Overspending
    
    // Goals progress (0-30 points)
    if (totalGoals > 0) {
      final goalProgress = (goalsCompleted / totalGoals) * 100;
      if (goalProgress >= 75) score += 30;
      else if (goalProgress >= 50) score += 20;
      else if (goalProgress >= 25) score += 10;
      else score += 5;
    } else {
      score += 15; // No goals set, neutral
    }
    
    return score.clamp(0, 100);
  }

  String get healthLabel {
    if (healthScore >= 80) return 'Excellent';
    if (healthScore >= 60) return 'Good';
    if (healthScore >= 40) return 'Fair';
    if (healthScore >= 20) return 'Needs Improvement';
    return 'Critical';
  }

  Color get healthColor {
    if (healthScore >= 80) return AppTheme.incomeColor; // Green
    if (healthScore >= 60) return Colors.blue; // Blue
    if (healthScore >= 40) return Colors.orange; // Orange
    if (healthScore >= 20) return Colors.amber; // Amber
    return AppTheme.expenseColor; // Red
  }

  String get healthEmoji {
    if (healthScore >= 80) return '🎉';
    if (healthScore >= 60) return '👍';
    if (healthScore >= 40) return '📊';
    if (healthScore >= 20) return '⚠️';
    return '🔴';
  }

  String get healthAdvice {
    if (healthScore >= 80) {
      return 'Keep up the great work! You\'re managing your finances excellently.';
    } else if (healthScore >= 60) {
      return 'You\'re doing well! Consider increasing your savings rate.';
    } else if (healthScore >= 40) {
      return 'Try to reduce expenses and set some financial goals.';
    } else if (healthScore >= 20) {
      return 'Focus on spending less than you earn and create a budget.';
    } else {
      return 'Start by tracking all expenses and creating a savings plan.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            healthColor.withOpacity(0.1),
            healthColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: healthColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: healthColor.withOpacity(0.1),
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
              Row(
                children: [
                  Text(
                    healthEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Financial Health',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: healthColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$healthScore',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            healthLabel,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: healthColor,
            ),
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: healthScore / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(healthColor),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            healthAdvice,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
