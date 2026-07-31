import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.messageId,
    required super.conversationId,
    required super.senderId,
    required super.text,
    required super.sentAt,
    required super.read,
  });

  factory ChatMessageModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
    String conversationId,
  ) {
    return ChatMessageModel(
      messageId: id,
      conversationId: conversationId,
      senderId: data['senderId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      sentAt: (data['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: data['read'] as bool? ?? false,
    );
  }
}