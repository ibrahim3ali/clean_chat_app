import '../../../../features.dart';

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
  });
}
