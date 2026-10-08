import 'package:flutter_test/flutter_test.dart';
import 'package:finewise/models/overview_period.dart';
import 'package:finewise/models/transaction.dart';

Transaction _tx(TransactionType type, double amount, DateTime date,
        {Category category = Category.food}) =>
    Transaction(
      id: '${date.millisecondsSinceEpoch}_$amount',
      type: type,
      category: category,
      amount: amount,
      description: 'test',
      date: date,
      account: AccountType.mobileMoney,
    );

void main() {
  group('OverviewPeriod', () {
    test('custom range includes both the first and the last day in full', () {
      final p = OverviewPeriod.custom(DateTime(2026, 9, 26), DateTime(2026, 10, 15));
      expect(p.contains(DateTime(2026, 9, 26, 0, 0)), isTrue);
      expect(p.contains(DateTime(2026, 10, 15, 23, 59)), isTrue);
      expect(p.contains(DateTime(2026, 9, 25, 23, 59)), isFalse);
      expect(p.contains(DateTime(2026, 10, 16)), isFalse);
    });

    test('stepping back from January lands on December of the previous year', () {
      final p = OverviewPeriod.month(2026, 1).step(-1);
      expect(p.start, DateTime(2025, 12));
      expect(p.end, DateTime(2026, 1));
    });

    test('last 60 days covers today and 59 days before it', () {
      final p = OverviewPeriod.lastDays(60);
      final now = DateTime.now();
      expect(p.contains(now), isTrue);
      expect(p.contains(DateTime(now.year, now.month, now.day - 59)), isTrue);
      expect(p.contains(DateTime(now.year, now.month, now.day - 60)), isFalse);
    });

    test('all time contains any date', () {
      expect(OverviewPeriod.allTime().contains(DateTime(2001, 5, 5)), isTrue);
    });
  });

  group('PeriodSummary', () {
    test('transfers and savings are not counted as spending', () {
      final d = DateTime(2026, 10, 1);
      final s = PeriodSummary.of([
        _tx(TransactionType.income, 1000, d),
        _tx(TransactionType.expense, 300, d),
        _tx(TransactionType.transfer, 500, d),
        _tx(TransactionType.expense, 200, d, category: Category.savings),
      ]);
      expect(s.moneyIn, 1000);
      expect(s.spent, 300);
      expect(s.left, 700);
      expect(s.count, 4);
    });
  });
}
