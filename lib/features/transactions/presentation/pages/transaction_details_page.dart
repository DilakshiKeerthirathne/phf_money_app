import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/money_transaction.dart';
import 'add_edit_transaction_page.dart';

class TransactionDetailsPage extends StatelessWidget {
  const TransactionDetailsPage({
    super.key,
    required this.transaction,
    required this.accountName,
    required this.categoryName,
  });

  final MoneyTransaction transaction;
  final String accountName;
  final String categoryName;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                '${isIncome ? '+' : '-'}${AppFormatters.currency(transaction.amount)}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isIncome ? AppColors.income : AppColors.expense,
                ),
              ),
            ),
            const SizedBox(height: 30),
            _InfoTile(
              title: 'Type',
              value: isIncome ? 'Income' : 'Expense',
            ),
            _InfoTile(
              title: 'Category',
              value: categoryName,
            ),
            _InfoTile(
              title: 'Account',
              value: accountName,
            ),
            _InfoTile(
              title: 'Date',
              value: AppFormatters.date(transaction.date),
            ),
            if (transaction.note != null)
              _InfoTile(
                title: 'Note',
                value: transaction.note!,
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Edit Transaction'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditTransactionPage(
                        existing: transaction,
                      ),
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
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(value),
      ),
    );
  }
}
