
import '../../../../features.dart';

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
  });
}
