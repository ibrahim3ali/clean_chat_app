import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/chat_conversation_entity.dart';
import 'chat_user_avatar.dart';

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
    final hasMessage = conversation.lastMessage.isNotEmpty;
    final isMe = conversation.lastSenderId == currentUserId;
    final subtitle = hasMessage
        ? (isMe ? '${context.tr('you')}: ${conversation.lastMessage}' : conversation.lastMessage)
        : context.tr('noMessagesTap');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          onTap: onTap,
          leading: ChatUserAvatar(
            name: conversation.otherUserName,
            isOnline: conversation.isOnline,
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  conversation.otherUserName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                ),
              ),
              if (conversation.lastMessageTime != null)
                Text(
                  DateFormatter.formatChatDate(conversation.lastMessageTime!),
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                ),
            ],
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
                color: hasMessage ? AppColors.textSecondary : AppColors.textMuted,
              ),
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
        ),
      ),
    );
  }
}
