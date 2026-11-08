import 'package:flutter/material.dart';
import '../../domain/entities/message_entity.dart';
import 'chat_bubble.dart';

class ChatMessagesList extends StatelessWidget {
  final List<MessageEntity> messages;
  final String currentUserId;

  const ChatMessagesList({
    super.key,
    required this.messages,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return ChatBubble(
          message: message,
          isMe: message.senderId == currentUserId,
        );
      },
    );
  }
}
