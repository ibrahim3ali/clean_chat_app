

import '../../../auth.dart';
import '../../data.dart';
import '../../domain.dart';

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
  }) {
    return remoteDataSource.sendMessage(
      currentUserId: currentUserId,
      currentUserName: currentUserName,
      receiverId: receiverId,
      text: text,
    );
  }
}
