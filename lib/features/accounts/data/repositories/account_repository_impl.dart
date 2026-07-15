import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/errors/app_exceptions.dart';
import '../../../../data/local/hive_boxes.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  Box<Map> get _box => Hive.box<Map>(HiveBoxes.accounts);

  @override
  Future<List<Account>> getAccounts() async {
    try {
      return _box.values.map((m) => Account.fromMap(m)).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } catch (e) {
      throw StorageException('Failed to load accounts: $e');
    }
  }

  @override
  Future<void> createAccount(Account account) async {
    try {
      await _box.put(account.id, account.toMap());
    } catch (e) {
      throw StorageException('Failed to create account: $e');
    }
  }

  @override
  Future<void> updateAccount(Account account) async {
    try {
      await _box.put(account.id, account.toMap());
    } catch (e) {
      throw StorageException('Failed to update account: $e');
    }
  }

  @override
  Future<void> deleteAccount(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw StorageException('Failed to delete account: $e');
    }
  }
}
