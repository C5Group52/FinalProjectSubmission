import 'package:equatable/equatable.dart';

enum TransactionType { earning, withdrawal }

enum TransactionStatus { pending, completed, failed }

class Transaction extends Equatable {
  const Transaction({
    required this.transactionId,
    required this.uid,
    required this.amountUsd,
    required this.type,
    required this.method,
    required this.status,
    required this.createdAt,
  });

  final String transactionId;
  final String uid;
  final double amountUsd;
  final TransactionType type;

  /// Payout channel, e.g. Telesom ZAAD. Earnings keep the same field so the
  /// history list can show one shape for both directions.
  final String method;
  final TransactionStatus status;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    transactionId,
    uid,
    amountUsd,
    type,
    method,
    status,
    createdAt,
  ];
}
