import 'package:flutter/material.dart';

enum TransactionType { income, expense }

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
  savings('Savings', '💰', 0xFFE8F5E9);

  final String name;
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

  Transaction({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
    required this.account,
    this.reason,
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
    );
  }
}
