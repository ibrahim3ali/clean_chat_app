import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/message_entity.dart';
import 'chat_audio_bubble.dart';
import 'chat_image_bubble.dart';
import 'chat_video_bubble.dart';

class ChatBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;

  const ChatBubble({super.key, required this.message, required this.isMe});

  Widget _buildContent() {
    if (message.isImage) {
      return ChatImageBubble(message: message, isMe: isMe);
    }
    if (message.isVideo) {
      return ChatVideoBubble(message: message, isMe: isMe);
    }
    if (message.isAudio) {
      return ChatAudioBubble(message: message, isMe: isMe);
    }

    return Column(
      crossAxisAlignment: isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message.text,
          style: TextStyle(
            color: isMe ? Colors.white : AppColors.textPrimary,
            fontSize: 15,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormatter.formatTime(message.timestamp),
          style: TextStyle(
            color: isMe ? Colors.white70 : AppColors.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.sentMessage : AppColors.receivedMessage,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _buildContent(),
      ),
    );
  }
}
