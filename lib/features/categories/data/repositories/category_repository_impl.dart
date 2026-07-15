import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../data/local/hive_boxes.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  Box<Map> get _box => Hive.box<Map>(HiveBoxes.categories);

  static const _defaultIncomeCategories = [
    'Salary',
    'Business',
    'Gift',
    'Other Income'
  ];
  static const _defaultExpenseCategories = [
    'Food',
    'Transport',
    'Bills',
    'Shopping',
    'Health',
    'Other Expense',
  ];

  @override
  Future<List<Category>> getCategories() async {
    try {
      return _box.values.map((m) => Category.fromMap(m)).toList();
    } catch (e) {
      throw StorageException('Failed to load categories: $e');
    }
  }

  @override
  Future<void> createCategory(Category category) async {
    try {
      await _box.put(category.id, category.toMap());
    } catch (e) {
      throw StorageException('Failed to create category: $e');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw StorageException('Failed to delete category: $e');
    }
  }

  @override
  Future<void> seedDefaultCategories() async {
    // Only seed once — never duplicate default categories on every app start.
    if (_box.isNotEmpty) return;

    for (final name in _defaultIncomeCategories) {
      final cat = Category(
          id: IdGenerator.generate(),
          name: name,
          type: CategoryType.income,
          isDefault: true);
      await _box.put(cat.id, cat.toMap());
    }
    for (final name in _defaultExpenseCategories) {
      final cat = Category(
          id: IdGenerator.generate(),
          name: name,
          type: CategoryType.expense,
          isDefault: true);
      await _box.put(cat.id, cat.toMap());
    }
  }
}
