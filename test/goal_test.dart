import 'package:flutter_test/flutter_test.dart';
import 'package:finewise/models/goal.dart';
import 'package:finewise/models/transaction.dart';

Goal _laptop({
  double target = 200000,
  List<GoalContribution> contributions = const [],
  List<GoalPriceChange> priceChanges = const [],
}) =>
    Goal(
      id: 'g1',
      name: 'Laptop',
      iconKey: 'laptop',
      targetAmount: target,
      targetDate: DateTime(2026, 12, 31),
      createdAt: DateTime(2026, 7, 1),
      contributions: contributions,
      priceChanges: priceChanges,
    );

GoalContribution _reserve(double amount, AccountType account) =>
    GoalContribution(
      id: 'c_$amount',
      amount: amount,
      date: DateTime(2026, 8, 1),
      account: account,
    );

void main() {
  group('price updates', () {
    test('a lower real price keeps the original plan and frees the extra', () {
      final goal = _laptop(
        target: 100000,
        contributions: [_reserve(150000, AccountType.mobileMoney)],
        priceChanges: [
          GoalPriceChange(from: 200000, to: 100000, date: DateTime(2026, 9, 1)),
        ],
      );
      expect(goal.plannedAmount, 200000);
      expect(goal.isCompleted, isTrue);
      expect(goal.extraReserved, 50000);
    });

    test('with no price updates the plan is the target', () {
      expect(_laptop().plannedAmount, 200000);
      expect(_laptop().priceWasUpdated, isFalse);
    });
  });

  group('split purchase', () {
    test('several linked payments survive a JSON round-trip', () {
      final bought = _laptop().copyWith(
        status: GoalStatus.purchased,
        purchasedAmount: 100000,
        purchasedDate: DateTime(2026, 10, 7),
        purchaseTransactionIds: ['momo_123', 'cash_456'],
      );
      final restored = Goal.fromJson(bought.toJson());
      expect(restored.purchaseTransactionIds, ['momo_123', 'cash_456']);
      expect(restored.purchasedAmount, 100000);
      expect(restored.isPurchased, isTrue);
    });

    test('a goal bought with an older version (single id) still loads', () {
      final json = _laptop().toJson()
        ..remove('purchaseTransactionIds')
        ..remove('priceChanges')
        ..['status'] = 'purchased'
        ..['purchasedAmount'] = 180000
        ..['purchaseTransactionId'] = 'goalbuy_1';
      final restored = Goal.fromJson(json);
      expect(restored.purchaseTransactionIds, ['goalbuy_1']);
      expect(restored.purchaseTransactionId, 'goalbuy_1');
      expect(restored.priceChanges, isEmpty);
    });
  });
}
