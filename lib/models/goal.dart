class Goal {
  final String id;
  final String name;
  final String emoji;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final DateTime createdAt;

  Goal({
    required this.id,
    required this.name,
    required this.emoji,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.createdAt,
  });

  double get progress => currentAmount / targetAmount;
  
  int get daysRemaining => targetDate.difference(DateTime.now()).inDays;
  
  bool get isCompleted => currentAmount >= targetAmount;

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      name: json['name'],
      emoji: json['emoji'],
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      targetDate: DateTime.parse(json['targetDate']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Create a copy with updated fields
  Goal copyWith({
    String? id,
    String? name,
    String? emoji,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    DateTime? createdAt,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
