import '../entities/account.dart';

/// Abstract contract. Presentation depends on this, never on Hive directly.
abstract class AccountRepository {
  Future<List<Account>> getAccounts();
  Future<void> createAccount(Account account);
  Future<void> updateAccount(Account account);
  Future<void> deleteAccount(String id);
}
