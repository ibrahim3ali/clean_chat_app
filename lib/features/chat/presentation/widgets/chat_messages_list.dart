import 'package:flutter/material.dart';

import '../../../../features.dart';

class ChatMessagesList extends StatelessWidget {
  final List<MessageEntity> messages;
  final String currentUserId;
  final Function(MessageEntity message, bool deleteForEveryone) onDeleteMessage;

  const ChatMessagesList({
    super.key,
    required this.messages,
    required this.currentUserId,
    required this.onDeleteMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.senderId == currentUserId;
        return ChatBubble(
          message: message,
          isMe: isMe,
          onLongPress: () {
            DeleteMessageDialog.show(
              context,
              isMe: isMe,
              onDelete: (deleteForEveryone) {
                onDeleteMessage(message, deleteForEveryone);
              },
            );
          },
        );
      },
    );
  }
}
