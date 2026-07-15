import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phf_money_app/features/reports/presentation/pages/reports_page.dart';
import 'package:phf_money_app/features/transactions/presentation/pages/add_edit_transaction_page.dart';
import 'package:phf_money_app/features/transactions/presentation/pages/transactions_page.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../../transactions/domain/entities/money_transaction.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/quick_actions.dart';
import '../widgets/budget_progress_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    final txnsAsync = ref.watch(transactionsProvider);
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];

    final loading = accountsAsync.isLoading || txnsAsync.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "PHF Money",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          )
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await ref.read(accountsProvider.notifier).refresh();

                await ref.read(transactionsProvider.notifier).refresh();
              },
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  _BalanceCard(
                    balance: ref.watch(totalBalanceProvider),
                  ),
                  const SizedBox(height: 20),
                  QuickActions(
                    onIncome: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddEditTransactionPage(
                            initialType: TransactionType.income,
                          ),
                        ),
                      );
                    },
                    onExpense: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddEditTransactionPage(
                            initialType: TransactionType.expense,
                          ),
                        ),
                      );
                    },
                    onReports: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReportsPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 25),
                  BudgetProgressCard(
                    totalBudget: 100000,
                    spent: ref.watch(monthlyExpenseProvider),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _MoneyCard(
                          title: "Income",
                          amount: ref.watch(monthlyIncomeProvider),
                          icon: Icons.arrow_downward,
                          color: AppColors.income,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MoneyCard(
                          title: "Expense",
                          amount: ref.watch(monthlyExpenseProvider),
                          icon: Icons.arrow_upward,
                          color: AppColors.expense,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MoneyCard(
                          title: "Savings",
                          amount: ref.watch(monthlySavingsProvider),
                          icon: Icons.savings,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Recent Transactions",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TransactionsPage(),
                            ),
                          );
                        },
                        child: const Text("View All"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _TransactionList(
                    transactions: ref.watch(recentTransactionsProvider),
                    categoryName: (id) {
                      final result = categories.where((c) => c.id == id);

                      return result.isEmpty ? "Unknown" : result.first.name;
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context) {
    final month = DateFormat("MMMM yyyy").format(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.phfBlueDark,
            AppColors.phfBlue,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.phfBlue.withValues(alpha: .35),
            blurRadius: 25,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                month,
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
              const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Total Balance",
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            AppFormatters.currency(balance),
            style: const TextStyle(
              fontSize: 34,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              "Manage • Save • Grow",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoneyCard extends StatelessWidget {
  const _MoneyCard(
      {required this.title,
      required this.amount,
      required this.icon,
      required this.color});

  final String title;

  final double amount;

  final IconData icon;

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: .15),
              child: Icon(
                icon,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              AppFormatters.currency(amount),
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ignore: unused_element
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _TransactionList extends StatelessWidget {
  const _TransactionList(
      {required this.transactions, required this.categoryName});

  final List<MoneyTransaction> transactions;

  final String Function(String) categoryName;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const EmptyState(
          icon: Icons.receipt_long,
          title: "No transactions yet",
          subtitle: "Start tracking your money");
    }

    return Column(
      children: transactions.map((t) {
        final income = t.type == TransactionType.income;

        return Card(
            child: ListTile(
          leading: CircleAvatar(
            backgroundColor: (income ? AppColors.income : AppColors.expense)
                .withValues(alpha: .15),
            child: Icon(
              income ? Icons.add : Icons.remove,
              color: income ? AppColors.income : AppColors.expense,
            ),
          ),
          title: Text(
            categoryName(t.categoryId),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(AppFormatters.date(t.date)),
          trailing: Text(
            "${income ? '+' : '-'}${AppFormatters.currency(t.amount)}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: income ? AppColors.income : AppColors.expense,
            ),
          ),
        ));
      }).toList(),
    );
  }
}
