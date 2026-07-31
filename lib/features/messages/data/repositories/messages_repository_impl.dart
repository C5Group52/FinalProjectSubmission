import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/messages_repository.dart';
import '../datasources/messages_remote_data_source.dart';

class MessagesRepositoryImpl implements MessagesRepository {
  MessagesRepositoryImpl(this._remote);

  final MessagesRemoteDataSource _remote;

  @override
  Future<String> getOrCreateSupportConversation(String uid) {
    return _remote.getOrCreateSupportConversation(uid);
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String conversationId) {
    return _remote.watchMessages(conversationId);
  }

  @override
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) {
    return _remote.sendMessage(
      conversationId: conversationId,
      senderId: senderId,
      text: text,
    );
  }
}