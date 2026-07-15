import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../accounts/presentation/providers/account_providers.dart';
import '../../../transactions/domain/entities/money_transaction.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';

/// Balance for a single account = opening balance + income - expense for that account.
double accountBalance(
    String accountId, double openingBalance, List<MoneyTransaction> txns) {
  var balance = openingBalance;
  for (final t in txns.where((t) => t.accountId == accountId)) {
    balance += t.type == TransactionType.income ? t.amount : -t.amount;
  }
  return balance;
}

final totalBalanceProvider = Provider<double>((ref) {
  final accounts = ref.watch(accountsProvider).valueOrNull ?? [];
  final txns = ref.watch(transactionsProvider).valueOrNull ?? [];
  return accounts.fold<double>(
      0, (sum, a) => sum + accountBalance(a.id, a.openingBalance, txns));
});

final monthlyIncomeProvider = Provider<double>((ref) {
  final txns = ref.watch(transactionsProvider).valueOrNull ?? [];
  final now = DateTime.now();
  return txns
      .where((t) =>
          t.type == TransactionType.income &&
          t.date.year == now.year &&
          t.date.month == now.month)
      .fold<double>(0, (sum, t) => sum + t.amount);
});

final monthlyExpenseProvider = Provider<double>((ref) {
  final txns = ref.watch(transactionsProvider).valueOrNull ?? [];
  final now = DateTime.now();
  return txns
      .where((t) =>
          t.type == TransactionType.expense &&
          t.date.year == now.year &&
          t.date.month == now.month)
      .fold<double>(0, (sum, t) => sum + t.amount);
});

final monthlySavingsProvider = Provider<double>((ref) {
  return ref.watch(monthlyIncomeProvider) - ref.watch(monthlyExpenseProvider);
});

final recentTransactionsProvider = Provider<List<MoneyTransaction>>((ref) {
  final txns = ref.watch(transactionsProvider).valueOrNull ?? [];
  final sorted = [...txns]..sort((a, b) => b.date.compareTo(a.date));
  return sorted.take(5).toList();
});
