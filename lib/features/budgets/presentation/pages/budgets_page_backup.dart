import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../domain/entities/budget.dart';
import '../providers/budget_providers.dart';

class BudgetsPage extends ConsumerWidget {
  const BudgetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedBudgetMonthProvider);
    final progressAsync = ref.watch(budgetsProvider); // triggers loading state
    final progress = ref.watch(budgetProgressProvider);
    final expenseCategories = (ref.watch(categoriesProvider).valueOrNull ?? [])
        .where((c) => c.type == CategoryType.expense)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      floatingActionButton: FloatingActionButton(
        onPressed: expenseCategories.isEmpty
            ? () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add an expense category first.')))
            : () => _showBudgetForm(context, ref, month, expenseCategories),
        child: const Icon(Icons.add),
      ),
      body: progressAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: _MonthSelector(month: month),
                ),
                if (progress.isNotEmpty) _BudgetSummaryCard(progress: progress),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: progress.isEmpty
                      ? const EmptyState(
                          icon: Icons.pie_chart_outline,
                          title: 'No budgets for this month',
                          subtitle:
                              'Tap + to set a spending limit for a category.',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md),
                          itemCount: progress.length,
                          itemBuilder: (context, i) {
                            final p = progress[i];
                            final categoryName = expenseCategories
                                .firstWhere(
                                  (c) => c.id == p.budget.categoryId,
                                  orElse: () => const Category(
                                      id: '',
                                      name: 'Unknown',
                                      type: CategoryType.expense,
                                      isDefault: false),
                                )
                                .name;
                            return _BudgetCard(
                                progress: p, categoryName: categoryName);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  void _showBudgetForm(BuildContext context, WidgetRef ref, String month,
      List<Category> categories) {
    String? categoryId;
    final limitController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Set Budget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: categoryId,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories
                    .map((c) =>
                        DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => setState(() => categoryId = v),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: limitController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Monthly limit'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                final limit = double.tryParse(limitController.text);
                if (categoryId == null || limit == null || limit <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          'Select a category and a limit greater than 0.')));
                  return;
                }
                ref.read(budgetsProvider.notifier).saveBudget(
                      Budget(
                        id: IdGenerator.generate(),
                        categoryId: categoryId!,
                        month: month,
                        limitAmount: limit,
                        createdAt: DateTime.now(),
                      ),
                    );
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthSelector extends ConsumerWidget {
  const _MonthSelector({required this.month});
  final String month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = DateFormat('yyyy-MM').parse(month);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            final prev = DateTime(current.year, current.month - 1);
            ref.read(selectedBudgetMonthProvider.notifier).state =
                DateFormat('yyyy-MM').format(prev);
          },
        ),
        Text(DateFormat('MMMM yyyy').format(current),
            style: Theme.of(context).textTheme.titleMedium),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            final next = DateTime(current.year, current.month + 1);
            ref.read(selectedBudgetMonthProvider.notifier).state =
                DateFormat('yyyy-MM').format(next);
          },
        ),
      ],
    );
  }
}

class _BudgetCard extends ConsumerWidget {
  const _BudgetCard({required this.progress, required this.categoryName});
  final BudgetProgress progress;
  final String categoryName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warn = progress.isOverOrNearLimit;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        categoryName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      _BudgetStatusChip(progress: progress),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () => ref
                      .read(budgetsProvider.notifier)
                      .deleteBudget(progress.budget.id),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress.ratio > 1 ? 1 : progress.ratio.toDouble(),
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                color: warn ? AppColors.expense : AppColors.phfBlue,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Spent: ${AppFormatters.currency(progress.spent)}',
                    style: const TextStyle(fontSize: 12)),
                Text(
                  progress.remaining >= 0
                      ? 'Remaining: ${AppFormatters.currency(progress.remaining)}'
                      : 'Over by: ${AppFormatters.currency(progress.remaining.abs())}',
                  style: TextStyle(
                    fontSize: 12,
                    color: warn ? AppColors.expense : Colors.grey.shade700,
                    fontWeight: warn ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress.ratio * 100).toStringAsFixed(0)}% of budget used',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: warn ? AppColors.expense : AppColors.phfBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetStatusChip extends StatelessWidget {
  const _BudgetStatusChip({required this.progress});

  final BudgetProgress progress;

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;

    if (progress.ratio >= 1) {
      text = 'Exceeded';
      color = AppColors.expense;
    } else if (progress.ratio >= 0.8) {
      text = 'Warning';
      color = Colors.orange;
    } else {
      text = 'Good';
      color = AppColors.income;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _BudgetSummaryCard extends StatelessWidget {
  const _BudgetSummaryCard({
    required this.progress,
  });

  final List<BudgetProgress> progress;

  @override
  Widget build(BuildContext context) {
    final totalBudget =
        progress.fold<double>(0, (sum, p) => sum + p.budget.limitAmount);

    final totalSpent = progress.fold<double>(0, (sum, p) => sum + p.spent);

    final remaining = totalBudget - totalSpent;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monthly Budget Summary',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Budget : ${AppFormatters.currency(totalBudget)}',
              ),
              Text(
                'Spent : ${AppFormatters.currency(totalSpent)}',
              ),
              Text(
                'Remaining : ${AppFormatters.currency(remaining)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: remaining >= 0 ? AppColors.income : AppColors.expense,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
