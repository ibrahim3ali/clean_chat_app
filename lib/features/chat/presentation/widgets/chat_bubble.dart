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
  final VoidCallback? onLongPress;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onLongPress,
  });

  Widget _buildContent(BuildContext context) {
    if (message.isImage) {
      return ChatImageBubble(message: message, isMe: isMe);
    }
    if (message.isVideo) {
      return ChatVideoBubble(message: message, isMe: isMe);
    }
    if (message.isAudio) {
      return ChatAudioBubble(message: message, isMe: isMe);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isMe
        ? Colors.white
        : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary);
    final timeColor = isMe
        ? Colors.white70
        : (isDark ? AppColors.darkTextSecondary : AppColors.textMuted);

    return Column(
      crossAxisAlignment: isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message.text,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormatter.formatTime(message.timestamp),
          style: TextStyle(
            color: timeColor,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            gradient: isMe ? AppColors.sentBubbleGradient : null,
            color: isMe
                ? null
                : (isDark
                    ? AppColors.darkReceivedMessage
                    : AppColors.receivedMessage),
            border: isMe
                ? null
                : Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : const Color(0xFFE2E8F0),
                    width: 0.8,
                  ),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isMe ? 20 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 20),
            ),
            boxShadow: [
              BoxShadow(
                color: isMe
                    ? const Color(0xFF9333EA).withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: isMe ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _buildContent(context),
        ),
      ),
    );
  }
}
