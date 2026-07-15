import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../core/widgets/empty_state.dart';

import '../../domain/entities/category.dart';
import '../providers/category_providers.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.phfBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Add"),
        onPressed: () => _showAddCategory(context, ref),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Failed to load categories: $e")),
        data: (categories) {
          if (categories.isEmpty) {
            return const EmptyState(
              icon: Icons.category_outlined,
              title: "No categories yet",
              subtitle:
                  "Create categories to organize your income and expenses.",
            );
          }

          final income =
              categories.where((c) => c.type == CategoryType.income).toList();

          final expense =
              categories.where((c) => c.type == CategoryType.expense).toList();

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _CategoryHeader(
                title: "Income Categories",
                count: income.length,
                color: AppColors.income,
                icon: Icons.trending_up,
              ),
              const SizedBox(height: 12),
              ...income.map(
                (c) => _CategoryCard(category: c),
              ),
              const SizedBox(height: 24),
              _CategoryHeader(
                title: "Expense Categories",
                count: expense.length,
                color: AppColors.expense,
                icon: Icons.trending_down,
              ),
              const SizedBox(height: 12),
              ...expense.map(
                (c) => _CategoryCard(category: c),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddCategory(
    BuildContext context,
    WidgetRef ref,
  ) {
    final controller = TextEditingController();

    var type = CategoryType.expense;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Add Category",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: "Category name",
                  prefixIcon: Icon(Icons.category_outlined),
                ),
              ),
              const SizedBox(height: 16),
              SegmentedButton<CategoryType>(
                segments: const [
                  ButtonSegment(
                    value: CategoryType.income,
                    label: Text("Income"),
                    icon: Icon(Icons.arrow_downward),
                  ),
                  ButtonSegment(
                    value: CategoryType.expense,
                    label: Text("Expense"),
                    icon: Icon(Icons.arrow_upward),
                  ),
                ],
                selected: {type},
                onSelectionChanged: (value) {
                  setState(() {
                    type = value.first;
                  });
                },
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Category name required",
                      ),
                    ),
                  );

                  return;
                }

                ref.read(categoriesProvider.notifier).addCategory(
                      Category(
                        id: IdGenerator.generate(),
                        name: name,
                        type: type,
                        isDefault: false,
                      ),
                    );

                Navigator.pop(ctx);
              },
              child: const Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  final String title;
  final int count;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.2),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _CategoryCard extends ConsumerWidget {
  const _CategoryCard({
    required this.category,
  });

  final Category category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIncome = category.type == CategoryType.income;

    final color = isIncome ? AppColors.income : AppColors.expense;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isIncome ? Icons.south_west : Icons.north_east,
            color: color,
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: category.isDefault
            ? const Text(
                "Default category",
              )
            : const Text(
                "Custom category",
              ),
        trailing: category.isDefault
            ? null
            : IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                ),
                color: Colors.redAccent,
                onPressed: () {
                  ref.read(categoriesProvider.notifier).deleteCategory(
                        category.id,
                      );
                },
              ),
      ),
    );
  }
}
