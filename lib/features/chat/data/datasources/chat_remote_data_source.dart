import 'dart:io';

import '../../../auth/data/models/user_model.dart';
import '../models/chat_conversation_model.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Stream<List<UserModel>> getUsersStream();
  Stream<List<ChatConversationModel>> getConversationsStream(
    String currentUserId,
  );
  Future<UserModel?> getUserByEmail(String email);
  Stream<List<MessageModel>> getMessagesStream({
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
  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
    required String currentUserId,
    required bool deleteForEveryone,
  });
  Future<void> clearChat({
    required String chatId,
    required String currentUserId,
    required bool deleteForEveryone,
  });
}
