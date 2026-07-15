enum TransactionType { income, expense }

/// Named MoneyTransaction (not "Transaction") to avoid clashing with
/// Dart/Flutter's own Transaction-related classes, per naming guidance.
class MoneyTransaction {
  const MoneyTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.accountId,
    required this.categoryId,
    required this.date,
    this.note,
    required this.createdAt,
  });

  final String id;
  final TransactionType type;
  final double amount;
  final String accountId;
  final String categoryId;
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  MoneyTransaction copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    String? accountId,
    String? categoryId,
    DateTime? date,
    String? note,
    DateTime? createdAt,
  }) {
    return MoneyTransaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'amount': amount,
        'accountId': accountId,
        'categoryId': categoryId,
        'date': date.toIso8601String(),
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };

  factory MoneyTransaction.fromMap(Map map) => MoneyTransaction(
        id: map['id'] as String,
        type: TransactionType.values.firstWhere((e) => e.name == map['type']),
        amount: (map['amount'] as num).toDouble(),
        accountId: map['accountId'] as String,
        categoryId: map['categoryId'] as String,
        date: DateTime.parse(map['date'] as String),
        note: map['note'] as String?,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}
