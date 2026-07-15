import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../../transactions/domain/entities/money_transaction.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';

/// The month currently selected on the Reports screen. Defaults to now.
final selectedReportMonthProvider = StateProvider<String>(
    (ref) => DateFormat('yyyy-MM').format(DateTime.now()));

class MonthlySummary {
  MonthlySummary({required this.income, required this.expense});
  final double income;
  final double expense;
  double get net => income - expense;
}

final monthlySummaryProvider = Provider<MonthlySummary>((ref) {
  final txns = ref.watch(transactionsProvider).valueOrNull ?? [];
  final month = ref.watch(selectedReportMonthProvider);

  final inMonth =
      txns.where((t) => DateFormat('yyyy-MM').format(t.date) == month);
  final income = inMonth
      .where((t) => t.type == TransactionType.income)
      .fold<double>(0, (sum, t) => sum + t.amount);
  final expense = inMonth
      .where((t) => t.type == TransactionType.expense)
      .fold<double>(0, (sum, t) => sum + t.amount);

  return MonthlySummary(income: income, expense: expense);
});

class CategoryBreakdownItem {
  CategoryBreakdownItem({required this.category, required this.amount});
  final Category category;
  final double amount;
}

/// Expense total per category for the selected month, sorted highest first.
/// Only categories with spending > 0 are included.
final categoryBreakdownProvider = Provider<List<CategoryBreakdownItem>>((ref) {
  final txns = ref.watch(transactionsProvider).valueOrNull ?? [];
  final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
  final month = ref.watch(selectedReportMonthProvider);

  final expenseTxns = txns.where((t) =>
      t.type == TransactionType.expense &&
      DateFormat('yyyy-MM').format(t.date) == month);

  final totals = <String, double>{};
  for (final t in expenseTxns) {
    totals[t.categoryId] = (totals[t.categoryId] ?? 0) + t.amount;
  }

  final items = totals.entries.map((e) {
    final cat = categories.where((c) => c.id == e.key);
    final category = cat.isEmpty
        ? Category(
            id: e.key,
            name: 'Unknown',
            type: CategoryType.expense,
            isDefault: false)
        : cat.first;
    return CategoryBreakdownItem(category: category, amount: e.value);
  }).toList();

  items.sort((a, b) => b.amount.compareTo(a.amount));
  return items;
});
