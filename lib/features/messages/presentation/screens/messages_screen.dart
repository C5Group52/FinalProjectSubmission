import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/widgets/sign_out_button.dart';
import '../providers/messages_providers.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationAsync = ref.watch(supportConversationIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Support Chat'),
        actions: const [SignOutButton()],
      ),
      body: conversationAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not open chat.\n$e')),
        data: (conversationId) {
          if (conversationId == null) return const SizedBox.shrink();
          return _ChatView(conversationId: conversationId);
        },
      ),
    );
  }
}

class _ChatView extends ConsumerStatefulWidget {
  const _ChatView({required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<_ChatView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _textController.text;
    if (text.trim().isEmpty) return;
    _textController.clear();
    await ref
        .read(sendMessageControllerProvider.notifier)
        .send(conversationId: widget.conversationId, text: text);
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(
      messagesStreamProvider(widget.conversationId),
    );
    final myUid = ref.watch(authStateChangesProvider).value?.uid;
    final isSending = ref.watch(sendMessageControllerProvider).isLoading;

    return Column(
      children: [
        Expanded(
          child: messagesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                Center(child: Text('Could not load messages.\n$e')),
            data: (messages) {
              if (messages.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Say hello! A SomTalent career coach typically replies within a day.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isMine = message.senderId == myUid;
                  return Align(
                    alignment: isMine
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: isMine
                            ? AppColors.primaryGreen
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(color: isMine ? Colors.white : null),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message…',
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: isSending ? null : _send,
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}