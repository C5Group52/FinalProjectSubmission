import '../entities/chat_message.dart';

abstract interface class MessagesRepository {
  /// Finds (or creates) the signed-in user's support conversation and
  /// returns its ID.
  Future<String> getOrCreateSupportConversation(String uid);

  Stream<List<ChatMessage>> watchMessages(String conversationId);

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
  });
}