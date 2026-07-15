/// A monthly spending limit for one category.
/// `month` is stored as 'yyyy-MM' (e.g. '2026-07') so budgets are always
/// scoped to a specific month, matching the guide's data model.
class Budget {
  const Budget({
    required this.id,
    required this.categoryId,
    required this.month,
    required this.limitAmount,
    required this.createdAt,
  });

  final String id;
  final String categoryId;
  final String month;
  final double limitAmount;
  final DateTime createdAt;

  Budget copyWith({double? limitAmount}) => Budget(
        id: id,
        categoryId: categoryId,
        month: month,
        limitAmount: limitAmount ?? this.limitAmount,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'categoryId': categoryId,
        'month': month,
        'limitAmount': limitAmount,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Budget.fromMap(Map map) => Budget(
        id: map['id'] as String,
        categoryId: map['categoryId'] as String,
        month: map['month'] as String,
        limitAmount: (map['limitAmount'] as num).toDouble(),
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}
