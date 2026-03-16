class Budget {
  final String id;
  final String name;
  final double amount;
  final String category;

  Budget({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'category': category,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as String,
      name: map['name'] as String,
      amount: map['amount'] as double,
      category: map['category'] as String,
    );
  }

  Budget copyWith({
    String? id,
    String? name,
    double? amount,
    String? category,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
    );
  }
}
