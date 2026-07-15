import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exceptions.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/entities/money_transaction.dart';
import '../../domain/repositories/transaction_repository.dart';

final transactionRepositoryProvider =
    Provider<TransactionRepository>((ref) => TransactionRepositoryImpl());

class TransactionsNotifier extends AsyncNotifier<List<MoneyTransaction>> {
  @override
  Future<List<MoneyTransaction>> build() {
    return ref.read(transactionRepositoryProvider).getTransactions();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(
        await ref.read(transactionRepositoryProvider).getTransactions());
  }

  /// Business rule validation lives here (domain-ish rule), not in the widget.
  Future<void> addTransaction(MoneyTransaction transaction) async {
    if (transaction.amount <= 0) {
      throw ValidationException('Amount must be greater than zero.');
    }
    await ref
        .read(transactionRepositoryProvider)
        .createTransaction(transaction);
    await refresh();
  }

  Future<void> updateTransaction(MoneyTransaction transaction) async {
    if (transaction.amount <= 0) {
      throw ValidationException('Amount must be greater than zero.');
    }
    await ref
        .read(transactionRepositoryProvider)
        .updateTransaction(transaction);
    await refresh();
  }

  Future<void> deleteTransaction(String id) async {
    await ref.read(transactionRepositoryProvider).deleteTransaction(id);
    await refresh();
  }

  Future<void> clearAll() async {
    final repo = ref.read(transactionRepositoryProvider);

    await repo.deleteAll();

    await refresh();
  }
}

final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<MoneyTransaction>>(
  TransactionsNotifier.new,
);
