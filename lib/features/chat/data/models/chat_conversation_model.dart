import '../../../../features.dart';

class ChatConversationModel extends ChatConversationEntity {
  const ChatConversationModel({
    required super.otherUserId,
    required super.otherUserName,
    required super.otherUserEmail,
    super.isOnline,
    super.lastMessage,
    super.lastMessageTime,
    super.lastSenderId,
  });
}
