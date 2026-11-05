import '../../../auth/domain/entities/user_entity.dart';
import '../entities/chat_conversation_entity.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  Stream<List<UserEntity>> getUsersStream();

  Stream<List<ChatConversationEntity>> getConversationsStream(String currentUserId);

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
