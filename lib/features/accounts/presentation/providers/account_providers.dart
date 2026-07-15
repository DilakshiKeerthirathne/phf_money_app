import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phf_money_app/features/transactions/presentation/providers/transaction_providers.dart';

import '../../data/repositories/account_repository_impl.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';

final accountRepositoryProvider =
    Provider<AccountRepository>((ref) => AccountRepositoryImpl());

/// Holds the current account list and exposes create/update/delete actions.
/// Presentation only talks to this notifier — never to Hive directly.
class AccountsNotifier extends AsyncNotifier<List<Account>> {
  @override
  Future<List<Account>> build() {
    return ref.read(accountRepositoryProvider).getAccounts();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await ref.read(accountRepositoryProvider).getAccounts());
  }

  Future<void> addAccount(Account account) async {
    await ref.read(accountRepositoryProvider).createAccount(account);
    await refresh();
  }

  Future<void> updateAccount(Account account) async {
    await ref.read(accountRepositoryProvider).updateAccount(account);
    await refresh();
  }

  Future<void> deleteAccount(String id) async {
    await ref.read(accountRepositoryProvider).deleteAccount(id);
    await refresh();
  }

  Future<void> clearAll() async {
    final repo = ref.read(transactionRepositoryProvider);

    await repo.deleteAll();

    await refresh();
  }
}

final accountsProvider = AsyncNotifierProvider<AccountsNotifier, List<Account>>(
    AccountsNotifier.new);
