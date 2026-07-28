import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/error/firebase_error_mapper.dart';
import '../models/chat_message_model.dart';

/// SomTalent's MVP messaging is a single support/mentor thread per job
/// seeker (no employer-to-employer chat yet — see docs/report "Known
/// Limitations"), so "the" conversation is found by an array-contains query
/// on [uid] rather than needing a conversation picker UI.
class MessagesRemoteDataSource {
  MessagesRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static const supportParticipantId = 'support';

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _conversations =>
      _firestore.collection(FirestorePaths.conversations);

  Future<String> getOrCreateSupportConversation(String uid) async {
    try {
      final existing = await _conversations
          .where('participantIds', arrayContains: uid)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) return existing.docs.first.id;

      final created = await _conversations.add({
        'participantIds': [uid, supportParticipantId],
        'lastMessage': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
      return created.id;
    } catch (e) {
      throw FirebaseErrorMapper.fromUnknown(e);
    }
  }

  Stream<List<ChatMessageModel>> watchMessages(String conversationId) {
    return _conversations
        .doc(conversationId)
        .collection(FirestorePaths.messagesSubcollection)
        .orderBy('sentAt')
        .snapshots()
        .map(
          (s) => s.docs
              .map(
                (d) => ChatMessageModel.fromFirestore(
                  d.data(),
                  d.id,
                  conversationId,
                ),
              )
              .toList(),
        );
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {
    try {
      final conversationRef = _conversations.doc(conversationId);
      await conversationRef
          .collection(FirestorePaths.messagesSubcollection)
          .add({
            'senderId': senderId,
            'text': text,
            'sentAt': FieldValue.serverTimestamp(),
            'read': false,
          });
      await conversationRef.update({
        'lastMessage': text,
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirebaseErrorMapper.fromUnknown(e);
    }
  }
}