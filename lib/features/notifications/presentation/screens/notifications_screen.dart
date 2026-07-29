import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/sign_out_button.dart';
import '../providers/notifications_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsStreamProvider);
    final markAsRead = ref.watch(markNotificationReadProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: const [SignOutButton()],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Could not load notifications.\n$e')),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(child: Text('You\'re all caught up.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: notifications.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final n = notifications[index];
              return ListTile(
                onTap: () => markAsRead(n.notificationId),
                leading: Icon(
                  Icons.circle,
                  size: 10,
                  color: n.read ? Colors.transparent : AppColors.primaryGreen,
                ),
                title: Text(
                  n.title,
                  style: TextStyle(
                    fontWeight: n.read ? FontWeight.w400 : FontWeight.w700,
                  ),
                ),
                subtitle: Text(n.body),
                trailing: Text(
                  DateFormat('MMM d').format(n.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            },
          );
        },
      ),
    );
  }
}