import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/error/firebase_error_mapper.dart';
import '../models/transaction_model.dart';

class EarningsRemoteDataSource {
  EarningsRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _transactions(String uid) =>
      _firestore
          .collection(FirestorePaths.users)
          .doc(uid)
          .collection(FirestorePaths.transactionsSubcollection);

  Stream<List<TransactionModel>> watchTransactions(String uid) {
    return _transactions(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (s) => s.docs
              .map((d) => TransactionModel.fromFirestore(d.data(), d.id, uid))
              .toList(),
        );
  }

  Future<void> requestWithdrawal({
    required String uid,
    required double amountUsd,
  }) async {
    try {
      await _transactions(uid).add({
        'amountUsd': amountUsd,
        'type': 'withdrawal',
        'method': 'TelesomZAAD',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirebaseErrorMapper.fromUnknown(e);
    }
  }
}
