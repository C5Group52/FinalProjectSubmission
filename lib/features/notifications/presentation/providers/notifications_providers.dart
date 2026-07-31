import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../jobs/presentation/providers/job_providers.dart';
import '../../data/datasources/notifications_remote_data_source.dart';
import '../../domain/entities/app_notification.dart';

final notificationsRemoteDataSourceProvider =
    Provider<NotificationsRemoteDataSource>((ref) {
      return NotificationsRemoteDataSource();
    });

final notificationsStreamProvider =
    StreamProvider.autoDispose<List<AppNotification>>((ref) {
      final uid = ref.watch(currentUidProvider);
      if (uid == null) return const Stream.empty();
      return ref
          .watch(notificationsRemoteDataSourceProvider)
          .watchNotifications(uid);
    });

final unreadNotificationsCountProvider = Provider.autoDispose<int>((ref) {
  final notifications =
      ref.watch(notificationsStreamProvider).value ?? const [];
  return notifications.where((n) => !n.read).length;
});

final markNotificationReadProvider =
    Provider.autoDispose<Future<void> Function(String notificationId)>((ref) {
      return (notificationId) {
        final uid = ref.read(currentUidProvider);
        if (uid == null) return Future.value();
        return ref
            .read(notificationsRemoteDataSourceProvider)
            .markAsRead(uid: uid, notificationId: notificationId);
      };
    });