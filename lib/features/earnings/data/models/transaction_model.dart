import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;

import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.transactionId,
    required super.uid,
    required super.amountUsd,
    required super.type,
    required super.method,
    required super.status,
    required super.createdAt,
  });

  factory TransactionModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
    String uid,
  ) {
    return TransactionModel(
      transactionId: id,
      uid: uid,
      amountUsd: (data['amountUsd'] as num?)?.toDouble() ?? 0,
      type: TransactionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => TransactionType.earning,
      ),
      method: data['method'] as String? ?? 'TelesomZAAD',
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TransactionStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'amountUsd': amountUsd,
    'type': type.name,
    'method': method,
    'status': status.name,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
