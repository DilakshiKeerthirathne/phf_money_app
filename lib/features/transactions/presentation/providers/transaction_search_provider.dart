import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../accounts/presentation/providers/account_providers.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../domain/entities/money_transaction.dart';
import 'transaction_providers.dart';

final transactionSearchProvider = StateProvider<String>((ref) => '');

final filteredTransactionsProvider = Provider<List<MoneyTransaction>>((ref) {
  final transactions = ref.watch(transactionsProvider).valueOrNull ?? [];

  final categories = ref.watch(categoriesProvider).valueOrNull ?? [];

  final accounts = ref.watch(accountsProvider).valueOrNull ?? [];

  final query = ref.watch(transactionSearchProvider).trim().toLowerCase();

  if (query.isEmpty) {
    return transactions;
  }

  return transactions.where((transaction) {
    categories.where((c) => c.id == transaction.categoryId);

    final amount = transaction.amount.toString();

    final note = (transaction.note ?? '').toLowerCase();

    final category = categories
            .where((c) => c.id == transaction.categoryId)
            .map((c) => c.name)
            .firstOrNull
            ?.toLowerCase() ??
        '';

    final account = accounts
            .where((a) => a.id == transaction.accountId)
            .map((a) => a.name)
            .firstOrNull
            ?.toLowerCase() ??
        '';

    return amount.contains(query) ||
        note.contains(query) ||
        category.contains(query) ||
        account.contains(query);
  }).toList();
});
