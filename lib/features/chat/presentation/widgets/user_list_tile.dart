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
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final titleColor =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final hasMessage = conversation.lastMessage.isNotEmpty;
    final isMe = conversation.lastSenderId == currentUserId;
    final isDeletedMessage = conversation.lastMessage.contains('🚫');
    final subtitle = hasMessage
        ? (isDeletedMessage
            ? conversation.lastMessage
            : (isMe
                ? '${context.tr('you')}: ${conversation.lastMessage}'
                : conversation.lastMessage))
        : context.tr('noMessagesTap');
    final subtitleColor = hasMessage
        ? (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)
        : (isDark ? AppColors.darkTextMuted : AppColors.textMuted);
    final timeColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor.withValues(alpha: 0.6), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                ChatUserAvatar(
                  name: conversation.otherUserName,
                  isOnline: conversation.isOnline,
                  radius: 26,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              conversation.otherUserName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: titleColor,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          if (conversation.lastMessageTime != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 6.0),
                              child: Text(
                                DateFormatter.formatChatDate(
                                  conversation.lastMessageTime!,
                                ),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: timeColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              hasMessage ? FontWeight.w500 : FontWeight.normal,
                          fontStyle: isDeletedMessage
                              ? FontStyle.italic
                              : FontStyle.normal,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
