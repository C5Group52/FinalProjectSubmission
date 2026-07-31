import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../jobs/presentation/providers/job_providers.dart';
import '../../data/datasources/messages_remote_data_source.dart';
import '../../data/repositories/messages_repository_impl.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/messages_repository.dart';

final messagesRemoteDataSourceProvider = Provider<MessagesRemoteDataSource>((
  ref,
) {
  return MessagesRemoteDataSource();
});

final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  return MessagesRepositoryImpl(ref.watch(messagesRemoteDataSourceProvider));
});

final supportConversationIdProvider = FutureProvider.autoDispose<String?>((
  ref,
) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Future.value(null);
  return ref
      .watch(messagesRepositoryProvider)
      .getOrCreateSupportConversation(uid);
});

final messagesStreamProvider = StreamProvider.autoDispose
    .family<List<ChatMessage>, String>((ref, conversationId) {
      return ref
          .watch(messagesRepositoryProvider)
          .watchMessages(conversationId);
    });

final sendMessageControllerProvider =
    AsyncNotifierProvider<SendMessageController, void>(
      SendMessageController.new,
    );

class SendMessageController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> send({
    required String conversationId,
    required String text,
  }) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null || text.trim().isEmpty) return false;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(messagesRepositoryProvider)
          .sendMessage(
            conversationId: conversationId,
            senderId: uid,
            text: text.trim(),
          ),
    );
    return !state.hasError;
  }
}