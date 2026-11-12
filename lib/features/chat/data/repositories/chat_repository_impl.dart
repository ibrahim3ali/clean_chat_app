import 'dart:io';

import '../../domain/entities/chat_conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';
import '../../../auth/domain/entities/user_entity.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<UserEntity>> getUsersStream() {
    return remoteDataSource.getUsersStream();
  }

  @override
  Stream<List<ChatConversationEntity>> getConversationsStream(
    String currentUserId,
  ) {
    return remoteDataSource.getConversationsStream(currentUserId);
  }

  @override
  Future<UserEntity?> getUserByEmail(String email) {
    return remoteDataSource.getUserByEmail(email);
  }

  @override
  Stream<List<MessageEntity>> getMessagesStream({
    required String currentUserId,
    required String otherUserId,
  }) {
    return remoteDataSource.getMessagesStream(
      currentUserId: currentUserId,
      otherUserId: otherUserId,
    );
  }

  @override
  Future<void> sendMessage({
    required String currentUserId,
    required String currentUserName,
    required String receiverId,
    required String text,
    String type = 'text',
    String? mediaUrl,
    int? mediaDuration,
  }) {
    return remoteDataSource.sendMessage(
      currentUserId: currentUserId,
      currentUserName: currentUserName,
      receiverId: receiverId,
      text: text,
      type: type,
      mediaUrl: mediaUrl,
      mediaDuration: mediaDuration,
    );
  }

  @override
  Future<String> uploadMediaFile({
    required File file,
    required String chatId,
    required String folder,
  }) {
    return remoteDataSource.uploadMediaFile(
      file: file,
      chatId: chatId,
      folder: folder,
    );
  }

  @override
  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
    required String currentUserId,
    required bool deleteForEveryone,
  }) {
    return remoteDataSource.deleteMessage(
      chatId: chatId,
      messageId: messageId,
      currentUserId: currentUserId,
      deleteForEveryone: deleteForEveryone,
    );
  }

  @override
  Future<void> clearChat({
    required String chatId,
    required String currentUserId,
    required bool deleteForEveryone,
  }) {
    return remoteDataSource.clearChat(
      chatId: chatId,
      currentUserId: currentUserId,
      deleteForEveryone: deleteForEveryone,
    );
  }
}
