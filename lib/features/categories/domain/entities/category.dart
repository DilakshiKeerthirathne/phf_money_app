enum CategoryType { income, expense }

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.isDefault,
  });

  final String id;
  final String name;
  final CategoryType type;
  final bool isDefault;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type.name,
        'isDefault': isDefault,
      };

  factory Category.fromMap(Map map) => Category(
        id: map['id'] as String,
        name: map['name'] as String,
        type: CategoryType.values.firstWhere((e) => e.name == map['type']),
        isDefault: map['isDefault'] as bool? ?? false,
      );
}
