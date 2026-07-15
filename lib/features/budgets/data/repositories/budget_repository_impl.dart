import 'package:hive_flutter/hive_flutter.dart';
import 'package:phf_money_app/features/budgets/domain/entities/budget.dart';

import '../../../../core/errors/app_exceptions.dart';
import '../../../../data/local/hive_boxes.dart';
import '../../domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  Box<Map> get _box => Hive.box<Map>(HiveBoxes.budgets);

  @override
  Future<List<Budget>> getBudgets() async {
    try {
      return _box.values.map((m) => Budget.fromMap(m)).toList();
    } catch (e) {
      throw StorageException('Failed to load budgets: $e');
    }
  }

  @override
  Future<void> upsertBudget(Budget budget) async {
    try {
      // Enforce one budget per category + month: reuse existing id if found.
      final existing = _box.values.map((m) => Budget.fromMap(m)).where(
          (b) => b.categoryId == budget.categoryId && b.month == budget.month);

      if (existing.isNotEmpty) {
        final target = existing.first.copyWith(limitAmount: budget.limitAmount);
        await _box.put(target.id, target.toMap());
      } else {
        await _box.put(budget.id, budget.toMap());
      }
    } catch (e) {
      throw StorageException('Failed to save budget: $e');
    }
  }

  @override
  Future<void> deleteBudget(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw StorageException('Failed to delete budget: $e');
    }
  }
}
