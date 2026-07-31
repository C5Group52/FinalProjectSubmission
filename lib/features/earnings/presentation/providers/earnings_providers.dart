import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../jobs/presentation/providers/job_providers.dart';
import '../../data/datasources/earnings_remote_data_source.dart';
import '../../data/repositories/earnings_repository_impl.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/earnings_repository.dart';

final earningsRemoteDataSourceProvider = Provider<EarningsRemoteDataSource>((
  ref,
) {
  return EarningsRemoteDataSource();
});

final earningsRepositoryProvider = Provider<EarningsRepository>((ref) {
  return EarningsRepositoryImpl(ref.watch(earningsRemoteDataSourceProvider));
});

final transactionsStreamProvider =
    StreamProvider.autoDispose<List<Transaction>>((ref) {
      final uid = ref.watch(currentUidProvider);
      if (uid == null) return const Stream.empty();
      return ref.watch(earningsRepositoryProvider).watchTransactions(uid);
    });

/// Earnings minus withdrawals. Failed withdrawals are ignored so a rejected
/// payout doesn't permanently eat into the balance.
final earningsBalanceProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsStreamProvider).value;
  if (transactions == null) return 0;

  var balance = 0.0;
  for (final t in transactions) {
    if (t.status == TransactionStatus.failed) continue;
    if (t.type == TransactionType.earning) {
      balance += t.amountUsd;
    } else {
      balance -= t.amountUsd;
    }
  }
  return balance;
});

final withdrawControllerProvider =
    AsyncNotifierProvider<WithdrawController, void>(WithdrawController.new);

class WithdrawController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> requestWithdrawal(double amountUsd) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return false;

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(earningsRepositoryProvider)
          .requestWithdrawal(uid: uid, amountUsd: amountUsd),
    );
    if (!state.hasError) {
      ref.invalidate(transactionsStreamProvider);
    }
    return !state.hasError;
  }
}
