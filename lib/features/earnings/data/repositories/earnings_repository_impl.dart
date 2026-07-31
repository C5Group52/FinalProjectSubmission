import '../../domain/entities/transaction.dart';
import '../../domain/repositories/earnings_repository.dart';
import '../datasources/earnings_remote_data_source.dart';

class EarningsRepositoryImpl implements EarningsRepository {
  EarningsRepositoryImpl(this._remote);

  final EarningsRemoteDataSource _remote;

  @override
  Stream<List<Transaction>> watchTransactions(String uid) =>
      _remote.watchTransactions(uid);

  @override
  Future<void> requestWithdrawal({
    required String uid,
    required double amountUsd,
  }) {
    return _remote.requestWithdrawal(uid: uid, amountUsd: amountUsd);
  }
}
