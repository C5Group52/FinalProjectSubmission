import '../entities/transaction.dart';

abstract interface class EarningsRepository {
  Stream<List<Transaction>> watchTransactions(String uid);

  Future<void> requestWithdrawal({
    required String uid,
    required double amountUsd,
  });
}
