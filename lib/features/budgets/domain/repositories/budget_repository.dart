import '../entities/budget.dart';

abstract class BudgetRepository {
  Future<List<Budget>> getBudgets();

  /// Creates a new budget, or updates the existing one if a budget
  /// already exists for the same category + month (avoids duplicates).
  Future<void> upsertBudget(Budget budget);

  Future<void> deleteBudget(String id);
}
