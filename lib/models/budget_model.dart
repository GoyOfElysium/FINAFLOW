class BudgetModel {
  final String id;
  final String categoryId;
  final double limit;
  double spent;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.limit,
    this.spent = 0.0,
  });

  double get percentage => limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
  double get remaining => (limit - spent).clamp(0.0, double.infinity);
  bool get isWarning => percentage >= 0.75 && percentage < 1.0;
  bool get isExceeded => spent >= limit;
  bool get isSafe => percentage < 0.75;

  BudgetStatus get status {
    if (isExceeded) return BudgetStatus.exceeded;
    if (isWarning) return BudgetStatus.warning;
    return BudgetStatus.safe;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'limit': limit,
      'spent': spent,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'],
      categoryId: map['categoryId'],
      limit: map['limit'],
      spent: map['spent'] ?? 0.0,
    );
  }

  BudgetModel copyWith({
    String? id,
    String? categoryId,
    double? limit,
    double? spent,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      limit: limit ?? this.limit,
      spent: spent ?? this.spent,
    );
  }
}

enum BudgetStatus { safe, warning, exceeded }
