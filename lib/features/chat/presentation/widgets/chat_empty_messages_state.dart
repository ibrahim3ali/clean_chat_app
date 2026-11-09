import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/localization_extension.dart';

class ChatEmptyMessagesState extends StatelessWidget {
  const ChatEmptyMessagesState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mark_chat_unread_outlined,
            size: 60,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            context.tr('noMessagesYet'),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
