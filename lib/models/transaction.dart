import 'package:flutter/material.dart';

enum TransactionType {
  income,
  expense,

  /// Money moved between the user's OWN accounts (e.g. Mobile Money to bank).
  ///
  /// This is neither a gain nor a loss — the user's total wealth is unchanged,
  /// the money simply sits somewhere else. Providers send TWO messages for one
  /// move ("you sent to bank" and "you received from wallet"), which would
  /// otherwise be recorded as an expense AND an income, inflating both totals
  /// and corrupting the savings rate.
  ///
  /// Transfers are therefore excluded from income totals, expense totals,
  /// spending charts and the savings rate. Any FEE charged on the transfer is
  /// recorded separately as a real expense, because that money genuinely left.
  transfer,
}

/// Which pot the money comes from / goes to.
enum AccountType { cash, mobileMoney, bank }

/// Why the user is spending (only relevant for expenses).
enum SpendingReason { necessity, business, enjoyment, emergency }

enum Category {
  food('Food', '🍔', 0xFFFFE8E8),
  transport('Transport', '🚗', 0xFFE8F5E9),
  entertainment('Entertainment', '🎮', 0xFFFFF3E0),
  utilities('Utilities', '💡', 0xFFE3F2FD),
  rent('Rent', '🏠', 0xFFF3E5F5),
  shopping('Shopping', '🛒', 0xFFFFEBEE),
  vacation('Vacation', '✈️', 0xFFE1F5FE),
  clothes('Clothes', '👕', 0xFFFFF9C4),
  water('Water', '💧', 0xFFE3F2FD),
  shoes('Shoes', '👟', 0xFFFFE0B2),
  health('Health', '🏥', 0xFFE8F5E9),
  education('Education', '🎓', 0xFFE3F2FD),
  family('Family & Support', '👨‍👩‍👧', 0xFFFFF8E1),
  debt('Debt & Loans', '💳', 0xFFFFEBEE),
  business('Business', '📦', 0xFFE1F5FE),
  giving('Giving & Church', '🙏', 0xFFEDE7F6),
  fees('Fees & Taxes', '📄', 0xFFE0F2F1),
  personal('Personal Care', '💅', 0xFFFFF3E0),
  medicine('Medicine', '💊', 0xFFE8F5E9),
  alcohol('Alcohol & Drinks', '🍷', 0xFFFFEBEE),
  tobacco('Tobacco', '🚬', 0xFFFFE0B2),
  income('Income', '💼', 0xFFE8F5E9),
  savings('Savings', '💰', 0xFFE8F5E9),
  other('Other', '💸', 0xFFECEFF1);

  final String name;

  /// Legacy field, no longer displayed anywhere. The UI uses [icon] instead —
  /// Material icons render consistently across devices and Android versions,
  /// whereas emoji appearance varies by vendor font and can look unpolished.
  /// Kept only so existing enum entries don't need rewriting.
  final String emoji;

  final int colorValue;

  const Category(this.name, this.emoji, this.colorValue);

  Color get color => Color(colorValue);

  IconData get icon {
    switch (this) {
      case Category.food:
        return Icons.restaurant;
      case Category.transport:
        return Icons.directions_car;
      case Category.entertainment:
        return Icons.videogame_asset;
      case Category.utilities:
        return Icons.lightbulb_outline;
      case Category.rent:
        return Icons.home_outlined;
      case Category.shopping:
        return Icons.shopping_bag_outlined;
      case Category.vacation:
        return Icons.flight_takeoff;
      case Category.clothes:
        return Icons.checkroom;
      case Category.water:
        return Icons.water_drop_outlined;
      case Category.shoes:
        return Icons.hiking;
      case Category.health:
        return Icons.local_hospital_outlined;
      case Category.education:
        return Icons.school_outlined;
      case Category.family:
        return Icons.family_restroom;
      case Category.debt:
        return Icons.credit_card;
      case Category.business:
        return Icons.business_center_outlined;
      case Category.giving:
        return Icons.volunteer_activism;
      case Category.fees:
        return Icons.receipt_long_outlined;
      case Category.personal:
        return Icons.spa_outlined;
      case Category.medicine:
        return Icons.medication_outlined;
      case Category.alcohol:
        return Icons.wine_bar_outlined;
      case Category.tobacco:
        return Icons.smoking_rooms_outlined;
      case Category.income:
        return Icons.account_balance_wallet_outlined;
      case Category.savings:
        return Icons.savings_outlined;
      case Category.other:
        return Icons.swap_horiz;
    }
  }
}

class Transaction {
  final String id;
  final TransactionType type;
  final Category category;
  final double amount;
  final String description;
  final DateTime date;
  final AccountType account;
  final SpendingReason? reason;

  /// True when this transaction was created automatically from a parsed
  /// Mobile Money SMS, rather than entered by hand. Shown as a small badge
  /// in the transaction list so auto-detected entries are easy to spot and
  /// double-check, since automatic parsing can occasionally get something
  /// wrong (amount, category, or direction) in a way manual entry can't.
  final bool isAutoDetected;

  /// The full original SMS text, kept only for auto-detected transactions.
  ///
  /// The list shows a short summary, but when the user opens a transaction
  /// they can read the provider's exact wording — which is the only way to
  /// check whether an amount, fee or direction was read correctly. Stays on
  /// the device and in the user's own account, same as every other field.
  final String? smsBody;

  Transaction({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
    required this.account,
    this.reason,
    this.isAutoDetected = false,
    this.smsBody,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'category': category.name,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'account': account.name,
      'reason': reason?.name,
      'isAutoDetected': isAutoDetected,
      'smsBody': smsBody,
    };
  }

  // Create from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      category: Category.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => Category.food,
      ),
      amount: (json['amount'] as num).toDouble(),
      description: json['description'],
      date: DateTime.parse(json['date']),
      account: AccountType.values.firstWhere(
        (e) => e.name == (json['account'] ?? 'mobileMoney'),
        orElse: () => AccountType.mobileMoney,
      ),
      reason: json['reason'] == null
          ? null
          : SpendingReason.values.firstWhere(
              (e) => e.name == json['reason'],
              orElse: () => SpendingReason.necessity,
            ),
      // Defaults to false for any transaction saved before this field
      // existed, so old local/Firestore data keeps loading correctly.
      isAutoDetected: json['isAutoDetected'] as bool? ?? false,
      // Null for anything recorded before the full message was kept, and for
      // every manually-entered transaction.
      smsBody: json['smsBody'] as String?,
    );
  }

  // Create a copy with updated fields
  Transaction copyWith({
    String? id,
    TransactionType? type,
    Category? category,
    double? amount,
    String? description,
    DateTime? date,
    AccountType? account,
    SpendingReason? reason,
    bool? isAutoDetected,
    String? smsBody,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      account: account ?? this.account,
      reason: reason ?? this.reason,
      isAutoDetected: isAutoDetected ?? this.isAutoDetected,
      smsBody: smsBody ?? this.smsBody,
    );
  }
}
