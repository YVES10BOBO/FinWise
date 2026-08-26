import 'package:flutter/material.dart';
import 'transaction.dart';

/// Lifecycle of a goal.
enum GoalStatus {
  /// Saving towards it — its contributions count as reserved money.
  active,

  /// The thing was bought. Contribution history is kept for the record, but
  /// the money is no longer reserved (it became a real expense).
  purchased,
}

/// A single movement of money into (or out of) a goal's reserved pot.
///
/// Contributions are TRANSFERS, never income or expenses: the money is still
/// yours, just committed to this goal. Recording them individually (rather
/// than as one running total) is what makes reserved money auditable, lets it
/// be attributed to a real account, and makes partial releases possible.
class GoalContribution {
  final String id;
  final double amount;
  final DateTime date;

  /// Which real account the money is reserved from (Cash / Bank / MoMo).
  final AccountType account;

  final String note;

  /// True when this record RETURNS money to the available balance instead of
  /// reserving it. Net reserved = contributions − releases.
  final bool isRelease;

  GoalContribution({
    required this.id,
    required this.amount,
    required this.date,
    required this.account,
    this.note = '',
    this.isRelease = false,
  });

  /// Signed value: positive reserves money, negative returns it.
  double get signedAmount => isRelease ? -amount : amount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'date': date.toIso8601String(),
        'account': account.name,
        'note': note,
        'isRelease': isRelease,
      };

  factory GoalContribution.fromJson(Map<String, dynamic> json) {
    return GoalContribution(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      account: AccountType.values.firstWhere(
        (a) => a.name == (json['account'] ?? 'cash'),
        orElse: () => AccountType.cash,
      ),
      note: (json['note'] as String?) ?? '',
      isRelease: (json['isRelease'] as bool?) ?? false,
    );
  }
}

class Goal {
  final String id;
  final String name;

  /// Key of the chosen icon (e.g. 'laptop'). Rendered via [icon] — NOT shown
  /// as raw text. Older records may contain an actual emoji character, which
  /// [icon] handles by falling back to a default.
  final String iconKey;

  final double targetAmount;
  final DateTime targetDate;
  final DateTime createdAt;

  /// Every reserve/release movement for this goal, newest last.
  final List<GoalContribution> contributions;

  final GoalStatus status;

  // Purchase details — populated when the goal is marked purchased.
  final double? purchasedAmount;
  final DateTime? purchasedDate;
  final String? purchaseTransactionId;

  Goal({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.targetAmount,
    required this.targetDate,
    required this.createdAt,
    this.contributions = const [],
    this.status = GoalStatus.active,
    this.purchasedAmount,
    this.purchasedDate,
    this.purchaseTransactionId,
  });

  /// Money currently reserved for this goal = contributions − releases.
  /// Derived from the history, so the two can never disagree.
  double get currentAmount {
    final total = contributions.fold<double>(0, (s, c) => s + c.signedAmount);
    return total < 0 ? 0 : total;
  }

  /// Reserved money broken down by the account it was taken from.
  Map<AccountType, double> get reservedByAccount {
    final map = <AccountType, double>{};
    for (final c in contributions) {
      map[c.account] = (map[c.account] ?? 0) + c.signedAmount;
    }
    map.removeWhere((_, v) => v <= 0);
    return map;
  }

  double get progress =>
      targetAmount <= 0 ? 0.0 : (currentAmount / targetAmount);

  int get daysRemaining => targetDate.difference(DateTime.now()).inDays;

  bool get isCompleted => currentAmount >= targetAmount;

  bool get isPurchased => status == GoalStatus.purchased;

  /// Amount still needed to hit the target.
  double get remaining {
    final r = targetAmount - currentAmount;
    return r < 0 ? 0 : r;
  }

  /// How much to set aside per month to reach the target by the date.
  double get monthlyNeeded {
    final days = daysRemaining;
    if (days <= 0) return remaining;
    final months = days / 30.0;
    return months > 0 ? remaining / months : remaining;
  }

  /// Icon for the stored key, with a safe fallback so a card never renders
  /// a raw key like "savings" as text.
  IconData get icon => goalIcons[iconKey] ?? Icons.flag_outlined;

  /// The selectable goal icons, shared by the picker and the cards.
  static const Map<String, IconData> goalIcons = {
    'savings': Icons.account_balance_wallet,
    'laptop': Icons.laptop_mac_outlined,
    'car': Icons.directions_car_outlined,
    'house': Icons.house_outlined,
    'land': Icons.landscape_outlined,
    'education': Icons.school_outlined,
    'business': Icons.storefront_outlined,
    'travel': Icons.flight_takeoff_outlined,
    'wedding': Icons.favorite_border,
    'family': Icons.family_restroom_outlined,
    'health': Icons.local_hospital_outlined,
    'emergency': Icons.shield_outlined,
    'phone': Icons.phone_iphone,
    'furniture': Icons.chair_outlined,
    'clothes': Icons.checkroom_outlined,
    'gaming': Icons.videogame_asset_outlined,
    'debt': Icons.receipt_long_outlined,
    'gift': Icons.card_giftcard_outlined,
    'other': Icons.flag_outlined,
  };

  /// Human-readable name for each icon, shown under it in the picker and on
  /// the goal card — an icon alone is easy to misread, and users pick the
  /// right category far more reliably when it's labelled.
  static const Map<String, String> goalIconLabels = {
    'savings': 'Savings',
    'laptop': 'Laptop',
    'car': 'Car',
    'house': 'House',
    'land': 'Land / Plot',
    'education': 'Education',
    'business': 'Business',
    'travel': 'Travel',
    'wedding': 'Wedding',
    'family': 'Family',
    'health': 'Health',
    'emergency': 'Emergency fund',
    'phone': 'Phone',
    'furniture': 'Furniture',
    'clothes': 'Clothes',
    'gaming': 'Gaming',
    'debt': 'Pay off debt',
    'gift': 'Gift',
    'other': 'Other',
  };

  /// Label for the stored key, with the same safe fallback as [icon].
  String get iconLabel => goalIconLabels[iconKey] ?? 'Other';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconKey': iconKey,
        // Kept for backward compatibility with older app versions.
        'emoji': iconKey,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
        'targetDate': targetDate.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'contributions': contributions.map((c) => c.toJson()).toList(),
        'status': status.name,
        // Always written (even as null) so a merged Firestore write CLEARS
        // these when a purchase is undone, instead of leaving stale values.
        'purchasedAmount': purchasedAmount,
        'purchasedDate': purchasedDate?.toIso8601String(),
        'purchaseTransactionId': purchaseTransactionId,
      };

  factory Goal.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.parse(json['createdAt']);

    // Contribution history (new format).
    final rawContribs = json['contributions'];
    var contributions = rawContribs is List
        ? rawContribs
            .map((e) => GoalContribution.fromJson(e as Map<String, dynamic>))
            .toList()
        : <GoalContribution>[];

    // Migration: goals saved before contribution history existed only had a
    // `currentAmount`. Seed a single legacy record so nothing is lost and the
    // derived total still matches what the user saw before.
    if (contributions.isEmpty) {
      final legacy = (json['currentAmount'] as num?)?.toDouble() ?? 0.0;
      if (legacy > 0) {
        contributions = [
          GoalContribution(
            id: 'legacy_${json['id']}',
            amount: legacy,
            date: createdAt,
            account: AccountType.cash,
            note: 'Reserved before contribution history was added',
          ),
        ];
      }
    }

    return Goal(
      id: json['id'],
      name: json['name'],
      // Prefer the new field; fall back to the old `emoji` field which held
      // the icon key in previous versions.
      iconKey: (json['iconKey'] as String?) ??
          (json['emoji'] as String?) ??
          'savings',
      targetAmount: (json['targetAmount'] as num).toDouble(),
      targetDate: DateTime.parse(json['targetDate']),
      createdAt: createdAt,
      contributions: contributions,
      status: GoalStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => GoalStatus.active,
      ),
      purchasedAmount: (json['purchasedAmount'] as num?)?.toDouble(),
      purchasedDate: json['purchasedDate'] != null
          ? DateTime.parse(json['purchasedDate'])
          : null,
      purchaseTransactionId: json['purchaseTransactionId'] as String?,
    );
  }

  Goal copyWith({
    String? id,
    String? name,
    String? iconKey,
    double? targetAmount,
    DateTime? targetDate,
    DateTime? createdAt,
    List<GoalContribution>? contributions,
    GoalStatus? status,
    double? purchasedAmount,
    DateTime? purchasedDate,
    String? purchaseTransactionId,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      targetAmount: targetAmount ?? this.targetAmount,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      contributions: contributions ?? this.contributions,
      status: status ?? this.status,
      purchasedAmount: purchasedAmount ?? this.purchasedAmount,
      purchasedDate: purchasedDate ?? this.purchasedDate,
      purchaseTransactionId:
          purchaseTransactionId ?? this.purchaseTransactionId,
    );
  }
}
