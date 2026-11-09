import 'package:equatable/equatable.dart';

import '../../../../features.dart';



class ChatConversationEntity extends Equatable {
  final String otherUserId;
  final String otherUserName;
  final String otherUserEmail;
  final bool isOnline;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final String lastSenderId;

  const ChatConversationEntity({
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserEmail,
    this.isOnline = false,
    this.lastMessage = '',
    this.lastMessageTime,
    this.lastSenderId = '',
  });

  UserEntity toUserEntity() {
    return UserEntity(
      uid: otherUserId,
      email: otherUserEmail,
      name: otherUserName,
      isOnline: isOnline,
    );
  }

  @override
  List<Object?> get props => [
    otherUserId,
    otherUserName,
    otherUserEmail,
    isOnline,
    lastMessage,
    lastMessageTime,
    lastSenderId,
  ];
}
