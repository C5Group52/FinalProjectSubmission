import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.sentAt,
    required this.read,
  });

  final String messageId;
  final String conversationId;
  final String senderId;
  final String text;
  final DateTime sentAt;
  final bool read;

  @override
  List<Object?> get props => [
    messageId,
    conversationId,
    senderId,
    text,
    sentAt,
    read,
  ];
}