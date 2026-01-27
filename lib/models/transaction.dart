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
  income('Income', '💼', 0xFFE8F5E9),
  savings('Savings', '💰', 0xFFE8F5E9);

  final String name;
  final String emoji;
  final int colorValue;

  const Category(this.name, this.emoji, this.colorValue);
  
  Color get color => Color(colorValue);
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
