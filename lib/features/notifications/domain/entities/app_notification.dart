import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  const AppNotification({
    required this.notificationId,
    required this.uid,
    required this.title,
    required this.body,
    required this.type,
    required this.read,
    required this.createdAt,
  });

  final String notificationId;
  final String uid;
  final String title;
  final String body;
  final String type;
  final bool read;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    notificationId,
    uid,
    title,
    body,
    type,
    read,
    createdAt,
  ];
}