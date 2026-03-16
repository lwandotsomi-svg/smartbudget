class Goal {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime createdDate;
  final DateTime targetDate;
  final String description;
  final bool isActive;

  Goal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.createdDate,
    required this.targetDate,
    required this.description,
    this.isActive = true,
  });

  double get progressPercentage {
    if (targetAmount <= 0) return 0;
    final percentage = (currentAmount / targetAmount) * 100;
    return percentage > 100 ? 100 : percentage;
  }

  double get remainingAmount {
    final remaining = targetAmount - currentAmount;
    return remaining > 0 ? remaining : 0;
  }

  bool get isGoalReached => currentAmount >= targetAmount;

  int get daysRemaining {
    final difference = targetDate.difference(DateTime.now());
    return difference.inDays;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'createdDate': createdDate.toIso8601String(),
      'targetDate': targetDate.toIso8601String(),
      'description': description,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] as String,
      title: map['title'] as String,
      targetAmount: (map['targetAmount'] as num).toDouble(),
      currentAmount: (map['currentAmount'] as num).toDouble(),
      createdDate: DateTime.parse(map['createdDate'] as String),
      targetDate: DateTime.parse(map['targetDate'] as String),
      description: map['description'] as String,
      isActive: (map['isActive'] as int) == 1,
    );
  }

  Goal copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? createdDate,
    DateTime? targetDate,
    String? description,
    bool? isActive,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      createdDate: createdDate ?? this.createdDate,
      targetDate: targetDate ?? this.targetDate,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Goal && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
