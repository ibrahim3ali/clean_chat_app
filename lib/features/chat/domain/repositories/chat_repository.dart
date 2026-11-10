import 'dart:io';

import '../entities/chat_conversation_entity.dart';
import '../entities/message_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';

abstract class ChatRepository {
  Stream<List<UserEntity>> getUsersStream();

  Stream<List<ChatConversationEntity>> getConversationsStream(
    String currentUserId,
  );

  Future<UserEntity?> getUserByEmail(String email);

  Stream<List<MessageEntity>> getMessagesStream({
    required String currentUserId,
    required String otherUserId,
  });

  Future<void> sendMessage({
    required String currentUserId,
    required String currentUserName,
    required String receiverId,
    required String text,
    String type = 'text',
    String? mediaUrl,
    int? mediaDuration,
  });

  Future<String> uploadMediaFile({
    required File file,
    required String chatId,
    required String folder,
  });
}
