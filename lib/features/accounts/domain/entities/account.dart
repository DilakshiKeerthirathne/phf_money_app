enum AccountType { cash, bank, card, wallet }

extension AccountTypeLabel on AccountType {
  String get label {
    switch (this) {
      case AccountType.cash:
        return 'Cash';
      case AccountType.bank:
        return 'Bank';
      case AccountType.card:
        return 'Card';
      case AccountType.wallet:
        return 'Wallet';
    }
  }
}

/// Domain entity. Pure Dart, no Flutter or Hive dependency.
class Account {
  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.openingBalance,
    required this.createdAt,
  });

  final String id;
  final String name;
  final AccountType type;
  final double openingBalance;
  final DateTime createdAt;

  Account copyWith({String? name, AccountType? type, double? openingBalance}) {
    return Account(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      openingBalance: openingBalance ?? this.openingBalance,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type.name,
        'openingBalance': openingBalance,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Account.fromMap(Map map) => Account(
        id: map['id'] as String,
        name: map['name'] as String,
        type: AccountType.values.firstWhere((e) => e.name == map['type']),
        openingBalance: (map['openingBalance'] as num).toDouble(),
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}
