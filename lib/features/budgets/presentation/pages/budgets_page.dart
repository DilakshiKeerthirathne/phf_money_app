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

    final budgetsState = ref.watch(budgetsProvider);

    final progress = ref.watch(budgetProgressProvider);

    final categories = (ref.watch(categoriesProvider).valueOrNull ?? [])
        .where(
          (c) => c.type == CategoryType.expense,
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Budgets",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "budget_fab",
        backgroundColor: AppColors.phfBlue,
        icon: const Icon(Icons.add),
        label: const Text(
          "New Budget",
        ),
        onPressed: categories.isEmpty
            ? () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Create expense category first",
                    ),
                  ),
                )
            : () => _showBudgetForm(context, ref, month, categories),
      ),
      body: budgetsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: _MonthSelector(
                    month: month,
                  ),
                ),
                if (progress.isNotEmpty)
                  _BudgetSummaryCard(
                    progress: progress,
                  ),
                const SizedBox(height: 12),
                Expanded(
                  child: progress.isEmpty
                      ? const EmptyState(
                          icon: Icons.pie_chart_outline,
                          title: "No budgets found",
                          subtitle: "Set monthly limits for your expenses",
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          itemCount: progress.length,
                          itemBuilder: (context, index) {
                            final item = progress[index];

                            final category = categories.firstWhere(
                              (c) => c.id == item.budget.categoryId,
                              orElse: () => const Category(
                                id: "",
                                name: "Unknown",
                                type: CategoryType.expense,
                                isDefault: false,
                              ),
                            );

                            return _BudgetCard(
                              progress: item,
                              categoryName: category.name,
                            );
                          },
                        ),
                )
              ],
            ),
    );
  }

  void _showBudgetForm(
    BuildContext context,
    WidgetRef ref,
    String month,
    List<Category> categories,
  ) {
    String? categoryId;

    final limitController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Create Budget",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Expense Category",
                  prefixIcon: Icon(Icons.category),
                ),
                items: categories
                    .map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => categoryId = v),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: limitController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Monthly Limit",
                  prefixIcon: Icon(Icons.money),
                ),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(limitController.text);

                if (categoryId == null || amount == null || amount <= 0) {
                  return;
                }

                ref.read(budgetsProvider.notifier).saveBudget(
                      Budget(
                        id: IdGenerator.generate(),
                        categoryId: categoryId!,
                        month: month,
                        limitAmount: amount,
                        createdAt: DateTime.now(),
                      ),
                    );

                Navigator.pop(ctx);
              },
              child: const Text(
                "Save",
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _MonthSelector extends ConsumerWidget {
  const _MonthSelector({
    required this.month,
  });

  final String month;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final date = DateFormat("yyyy-MM").parse(month);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              final previous = DateTime(
                date.year,
                date.month - 1,
              );

              ref.read(selectedBudgetMonthProvider.notifier).state =
                  DateFormat("yyyy-MM").format(previous);
            },
          ),
          Text(
            DateFormat("MMMM yyyy").format(date),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              final next = DateTime(
                date.year,
                date.month + 1,
              );

              ref.read(selectedBudgetMonthProvider.notifier).state =
                  DateFormat("yyyy-MM").format(next);
            },
          )
        ],
      ),
    );
  }
}

class _BudgetCard extends ConsumerWidget {
  const _BudgetCard({
    required this.progress,
    required this.categoryName,
  });

  final BudgetProgress progress;
  final String categoryName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWarning = progress.isOverOrNearLimit;

    final progressValue = progress.ratio > 1 ? 1.0 : progress.ratio.toDouble();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.phfBlue.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: AppColors.phfBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    categoryName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StatusChip(progress: progress),
              ],
            ),

            const SizedBox(height: 18),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: progressValue,
                minHeight: 10,
                backgroundColor: Colors.grey.withValues(alpha: .2),
                color: isWarning ? AppColors.expense : AppColors.phfBlue,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Spent",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      AppFormatters.currency(
                        progress.spent,
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "Limit",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      AppFormatters.currency(
                        progress.budget.limitAmount,
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${progress.percentage}% used",
                  style: TextStyle(
                    color: isWarning ? AppColors.expense : AppColors.phfBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    ref
                        .read(
                          budgetsProvider.notifier,
                        )
                        .deleteBudget(
                          progress.budget.id,
                        );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.progress,
  });

  final BudgetProgress progress;

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;

    if (progress.isOverBudget) {
      text = "Exceeded";
      color = AppColors.expense;
    } else if (progress.isNearLimit) {
      text = "Warning";
      color = Colors.orange;
    } else {
      text = "Safe";
      color = AppColors.income;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
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
    final totalBudget = progress.fold<double>(
      0,
      (sum, item) => sum + item.budget.limitAmount,
    );

    final totalSpent = progress.fold<double>(
      0,
      (sum, item) => sum + item.spent,
    );

    final remaining = totalBudget - totalSpent;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Monthly Budget Summary",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _SummaryItem(
                      title: "Budget",
                      value: totalBudget,
                      color: AppColors.phfBlue,
                    ),
                  ),
                  Expanded(
                    child: _SummaryItem(
                      title: "Spent",
                      value: totalSpent,
                      color: AppColors.expense,
                    ),
                  ),
                  Expanded(
                    child: _SummaryItem(
                      title: "Left",
                      value: remaining,
                      color:
                          remaining >= 0 ? AppColors.income : AppColors.expense,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          AppFormatters.currency(value),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
