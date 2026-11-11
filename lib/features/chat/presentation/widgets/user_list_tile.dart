import 'package:flutter/material.dart';

import '../../../../core.dart';
import '../../../../features.dart';

class UserListTile extends StatelessWidget {
  final ChatConversationEntity conversation;
  final String currentUserId;
  final VoidCallback onTap;

  const UserListTile({
    super.key,
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final titleColor =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final hasMessage = conversation.lastMessage.isNotEmpty;
    final isMe = conversation.lastSenderId == currentUserId;
    final subtitle = hasMessage
        ? (isMe
              ? '${context.tr('you')}: ${conversation.lastMessage}'
              : conversation.lastMessage)
        : context.tr('noMessagesTap');
    final subtitleColor = hasMessage
        ? (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)
        : (isDark ? AppColors.darkTextMuted : AppColors.textMuted);
    final timeColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          onTap: onTap,
          leading: ChatUserAvatar(
            name: conversation.otherUserName,
            isOnline: conversation.isOnline,
          ),
          title: Text(
            conversation.otherUserName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: titleColor,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: hasMessage ? FontWeight.w500 : FontWeight.normal,
                color: subtitleColor,
              ),
            ),
          ),
          trailing: (conversation.lastMessageTime != null)
              ? Text(
                  DateFormatter.formatChatDate(conversation.lastMessageTime!),
                  style: TextStyle(
                    fontSize: 11,
                    color: timeColor,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
