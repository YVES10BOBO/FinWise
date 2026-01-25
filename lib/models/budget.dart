import 'transaction.dart';

class Budget {
  final Category category;
  final double allocated;
  final double spent;

  Budget({
    required this.category,
    required this.allocated,
    required this.spent,
  });

  double get remaining => allocated - spent;
  double get percentage => (spent / allocated) * 100;
  bool get isOverBudget => spent > allocated;
}
