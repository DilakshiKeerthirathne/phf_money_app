import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';

import '../../../accounts/presentation/providers/account_providers.dart';
import '../../../categories/presentation/providers/category_providers.dart';

import '../../domain/entities/money_transaction.dart';

import '../providers/transaction_providers.dart';
import '../providers/transaction_search_provider.dart';

import 'add_edit_transaction_page.dart';
import 'transaction_details_page.dart';
import '../../../../core/widgets/phf_background.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider).valueOrNull ?? [];

    final filtered = ref.watch(filteredTransactionsProvider);

    final accounts = ref.watch(accountsProvider).valueOrNull ?? [];

    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];

    String accountName(String id) {
      final result = accounts.where((a) => a.id == id);

      return result.isEmpty ? "Unknown" : result.first.name;
    }

    String categoryName(String id) {
      final result = categories.where((c) => c.id == id);

      return result.isEmpty ? "Unknown" : result.first.name;
    }

    final income =
        transactions.where((t) => t.type == TransactionType.income).length;

    final expense =
        transactions.where((t) => t.type == TransactionType.expense).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Transactions",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "transaction_fab",
        backgroundColor: AppColors.phfBlue,
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          "New Transaction",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () {
          if (accounts.isEmpty || categories.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Add account and category first",
                ),
              ),
            );

            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditTransactionPage(),
            ),
          );
        },
      ),
      body: PHFBackground(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: _SummaryHeader(
                total: transactions.length,
                income: income,
                expense: expense,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search transactions",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  ref.read(transactionSearchProvider.notifier).state = value;
                },
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: filtered.isEmpty
                  ? const EmptyState(
                      icon: Icons.receipt_long,
                      title: "No transactions",
                      subtitle: "Add income or expense",
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final t = filtered[index];

                        final income = t.type == TransactionType.income;

                        return Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(10),
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor: (income
                                      ? AppColors.income
                                      : AppColors.expense)
                                  .withValues(alpha: .15),
                              child: Icon(
                                income ? Icons.add : Icons.remove,
                                color: income
                                    ? AppColors.income
                                    : AppColors.expense,
                              ),
                            ),
                            title: Text(
                              categoryName(t.categoryId),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  accountName(t.accountId),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  AppFormatters.date(t.date),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Text(
                              "${income ? '+' : '-'}${AppFormatters.currency(t.amount)}",
                              style: TextStyle(
                                color: income
                                    ? AppColors.income
                                    : AppColors.expense,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TransactionDetailsPage(
                                    transaction: t,
                                    accountName: accountName(t.accountId),
                                    categoryName: categoryName(t.categoryId),
                                  ),
                                ),
                              );
                            },
                            onLongPress: () {
                              _confirmDelete(context, ref, t.id);
                            },
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete transaction?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              ref.read(transactionsProvider.notifier).deleteTransaction(id);

              Navigator.pop(ctx);
            },
            child: const Text("Delete"),
          )
        ],
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({
    required this.total,
    required this.income,
    required this.expense,
  });

  final int total;
  final int income;
  final int expense;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _buildItem(
                "Total", total.toString(), Icons.receipt, AppColors.phfBlue)),
        Expanded(
            child: _buildItem("Income", income.toString(), Icons.arrow_downward,
                AppColors.income)),
        Expanded(
            child: _buildItem("Expense", expense.toString(), Icons.arrow_upward,
                AppColors.expense)),
      ],
    );
  }

  Widget _buildItem(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
            ),
          )
        ],
      ),
    );
  }
}
