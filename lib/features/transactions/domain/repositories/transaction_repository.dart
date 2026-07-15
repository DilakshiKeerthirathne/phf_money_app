import '../entities/money_transaction.dart';

abstract class TransactionRepository {
  Future<List<MoneyTransaction>> getTransactions();
  Future<void> createTransaction(MoneyTransaction transaction);
  Future<void> updateTransaction(MoneyTransaction transaction);
  Future<void> deleteTransaction(String id);

  Future<void> deleteAll() async {}
}
