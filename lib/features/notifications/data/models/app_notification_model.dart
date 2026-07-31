import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/app_notification.dart';

class AppNotificationModel extends AppNotification {
  const AppNotificationModel({
    required super.notificationId,
    required super.uid,
    required super.title,
    required super.body,
    required super.type,
    required super.read,
    required super.createdAt,
  });

  factory AppNotificationModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
    String uid,
  ) {
    return AppNotificationModel(
      notificationId: id,
      uid: uid,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      type: data['type'] as String? ?? 'general',
      read: data['read'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}