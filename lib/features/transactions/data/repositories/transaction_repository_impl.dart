import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/errors/app_exceptions.dart';
import '../../../../data/local/hive_boxes.dart';
import '../../domain/entities/money_transaction.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  Box<Map> get _box => Hive.box<Map>(HiveBoxes.transactions);

  @override
  Future<List<MoneyTransaction>> getTransactions() async {
    try {
      final list = _box.values.map((m) => MoneyTransaction.fromMap(m)).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    } catch (e) {
      throw StorageException('Failed to load transactions: $e');
    }
  }

  @override
  Future<void> createTransaction(MoneyTransaction transaction) async {
    try {
      await _box.put(transaction.id, transaction.toMap());
    } catch (e) {
      throw StorageException('Failed to create transaction: $e');
    }
  }

  @override
  Future<void> updateTransaction(MoneyTransaction transaction) async {
    try {
      await _box.put(transaction.id, transaction.toMap());
    } catch (e) {
      throw StorageException('Failed to update transaction: $e');
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw StorageException('Failed to delete transaction: $e');
    }
  }

  @override
  Future<void> deleteAll() async {
    final box = Hive.box<Map>(HiveBoxes.transactions);

    await box.clear();
  }
}
