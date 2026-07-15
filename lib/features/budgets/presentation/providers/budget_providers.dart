import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../transactions/domain/entities/money_transaction.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../data/repositories/budget_repository_impl.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';

final budgetRepositoryProvider =
    Provider<BudgetRepository>((ref) => BudgetRepositoryImpl());

/// The month currently selected on the Budgets screen. Defaults to now.
final selectedBudgetMonthProvider = StateProvider<String>(
    (ref) => DateFormat('yyyy-MM').format(DateTime.now()));

class BudgetsNotifier extends AsyncNotifier<List<Budget>> {
  @override
  Future<List<Budget>> build() {
    return ref.read(budgetRepositoryProvider).getBudgets();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await ref.read(budgetRepositoryProvider).getBudgets());
  }

  Future<void> saveBudget(Budget budget) async {
    if (budget.limitAmount <= 0) return;
    await ref.read(budgetRepositoryProvider).upsertBudget(budget);
    await refresh();
  }

  Future<void> deleteBudget(String id) async {
    await ref.read(budgetRepositoryProvider).deleteBudget(id);
    await refresh();
  }

  Future<void> clearAll() async {
    final repo = ref.read(transactionRepositoryProvider);

    await repo.deleteAll();

    await refresh();
  }
}

final budgetsProvider =
    AsyncNotifierProvider<BudgetsNotifier, List<Budget>>(BudgetsNotifier.new);

/// Amount already spent for a category in a given month, calculated
/// straight from real transactions (never a manually typed number).
double spentForCategoryMonth(
    String categoryId, String month, List<MoneyTransaction> txns) {
  return txns
      .where((t) =>
          t.type == TransactionType.expense &&
          t.categoryId == categoryId &&
          DateFormat('yyyy-MM').format(t.date) == month)
      .fold<double>(0, (sum, t) => sum + t.amount);
}

/// Budgets for the currently selected month, paired with spent/remaining.
final budgetProgressProvider = Provider<List<BudgetProgress>>((ref) {
  final budgets = ref.watch(budgetsProvider).valueOrNull ?? [];
  final txns = ref.watch(transactionsProvider).valueOrNull ?? [];
  final month = ref.watch(selectedBudgetMonthProvider);

  return budgets.where((b) => b.month == month).map((b) {
    final spent = spentForCategoryMonth(b.categoryId, month, txns);
    return BudgetProgress(budget: b, spent: spent);
  }).toList();
});

class BudgetProgress {
  BudgetProgress({
    required this.budget,
    required this.spent,
  });

  final Budget budget;
  final double spent;

  double get remaining => budget.limitAmount - spent;

  double get ratio => budget.limitAmount <= 0 ? 0 : spent / budget.limitAmount;

  int get percentage => (ratio * 100).round();

  bool get isNearLimit => ratio >= 0.8 && ratio < 1;

  bool get isOverBudget => ratio >= 1;

  bool get isSafe => ratio < 0.8;

  bool get isOverOrNearLimit => ratio >= 0.8;
}
