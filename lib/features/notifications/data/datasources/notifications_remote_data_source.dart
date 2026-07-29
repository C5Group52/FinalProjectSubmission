import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../models/app_notification_model.dart';

class NotificationsRemoteDataSource {
  NotificationsRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _notifications(String uid) =>
      _firestore
          .collection(FirestorePaths.users)
          .doc(uid)
          .collection(FirestorePaths.notificationsSubcollection);

  Stream<List<AppNotificationModel>> watchNotifications(String uid) {
    return _notifications(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (s) => s.docs
              .map(
                (d) => AppNotificationModel.fromFirestore(d.data(), d.id, uid),
              )
              .toList(),
        );
  }

  Future<void> create({
    required String uid,
    required String title,
    required String body,
    required String type,
  }) {
    return _notifications(uid).add({
      'title': title,
      'body': body,
      'type': type,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markAsRead({
    required String uid,
    required String notificationId,
  }) {
    return _notifications(uid).doc(notificationId).update({'read': true});
  }
}
