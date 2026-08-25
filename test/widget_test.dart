import 'package:flutter_test/flutter_test.dart';
import 'package:finewise/models/transaction.dart';

/// Persistence tests for the Transaction model.
///
/// Transactions are cached as JSON in SharedPreferences and mirrored to
/// Firestore, so a change to this model has to stay readable against records
/// written by OLDER versions of the app — otherwise an upgrade silently
/// wipes someone's history. `TransactionType.transfer` was added partway
/// through the project, which makes that risk real rather than theoretical.
void main() {
  group('Transaction JSON round-trip', () {
    test('an expense survives encode/decode unchanged', () {
      final original = Transaction(
        id: 'momo_12345',
        type: TransactionType.expense,
        category: Category.shopping,
        amount: 220,
        description: 'Your payment of 200 RWF to David was completed',
        date: DateTime(2026, 8, 25, 10, 29, 20),
        account: AccountType.mobileMoney,
        isAutoDetected: true,
      );

      final restored = Transaction.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.type, original.type);
      expect(restored.category, original.category);
      expect(restored.amount, original.amount);
      expect(restored.description, original.description);
      expect(restored.date, original.date);
      expect(restored.account, original.account);
      expect(restored.isAutoDetected, original.isAutoDetected);
    });

    test('a transfer survives encode/decode unchanged', () {
      final original = Transaction(
        id: 'momo_29971903286',
        type: TransactionType.transfer,
        category: Category.other,
        amount: 4900,
        description: 'Transfer between accounts',
        date: DateTime(2026, 8, 19, 14, 18),
        account: AccountType.mobileMoney,
        isAutoDetected: true,
      );

      final restored = Transaction.fromJson(original.toJson());

      expect(restored.type, TransactionType.transfer);
      expect(restored.amount, 4900);
    });

    test('records written before "transfer" existed still parse', () {
      // Exactly the shape an older build would have persisted.
      final legacy = {
        'id': 'old_record_1',
        'type': 'expense',
        'category': 'food',
        'amount': 1500.0,
        'description': 'Lunch',
        'date': DateTime(2026, 1, 1).toIso8601String(),
        'account': 'cash',
        'isAutoDetected': false,
      };

      final restored = Transaction.fromJson(legacy);

      expect(restored.type, TransactionType.expense);
      expect(restored.amount, 1500);
      expect(restored.account, AccountType.cash);
    });
  });

  group('transfer semantics', () {
    test('transfer is a distinct type from income and expense', () {
      // The whole "money moved between your own accounts isn't a gain or a
      // loss" behaviour depends on this staying a separate case, so every
      // total must be able to filter it out explicitly.
      expect(TransactionType.values, contains(TransactionType.transfer));
      expect(TransactionType.transfer, isNot(TransactionType.income));
      expect(TransactionType.transfer, isNot(TransactionType.expense));
    });

    test('summing a list the way the app does excludes transfers', () {
      final transactions = [
        Transaction(
          id: '1',
          type: TransactionType.income,
          category: Category.income,
          amount: 5000,
          description: 'Salary',
          date: DateTime(2026, 8, 1),
          account: AccountType.bank,
        ),
        Transaction(
          id: '2',
          type: TransactionType.expense,
          category: Category.food,
          amount: 2000,
          description: 'Groceries',
          date: DateTime(2026, 8, 2),
          account: AccountType.cash,
        ),
        Transaction(
          id: '3',
          type: TransactionType.transfer,
          category: Category.other,
          amount: 100000, // deliberately huge — must not move any total
          description: 'Transfer between accounts',
          date: DateTime(2026, 8, 3),
          account: AccountType.mobileMoney,
        ),
      ];

      final income = transactions
          .where((t) => t.type == TransactionType.income)
          .fold<double>(0, (sum, t) => sum + t.amount);
      final expenses = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold<double>(0, (sum, t) => sum + t.amount);

      expect(income, 5000);
      expect(expenses, 2000);
      expect(income - expenses, 3000);
    });
  });
}
