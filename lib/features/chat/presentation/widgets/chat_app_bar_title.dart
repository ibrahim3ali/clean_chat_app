import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../auth/domain/entities/user_entity.dart';

class ChatAppBarTitle extends StatelessWidget {
  final UserEntity otherUser;
  final Stream<bool> typingStream;

  const ChatAppBarTitle({
    super.key,
    required this.otherUser,
    required this.typingStream,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          child: Text(
            otherUser.name.isNotEmpty ? otherUser.name.characters.first.toUpperCase() : '?',
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              otherUser.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            StreamBuilder<bool>(
              stream: typingStream,
              builder: (context, snapshot) {
                final isTyping = snapshot.data == true;
                if (isTyping) {
                  return Text(
                    context.tr('typing'),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                  );
                }
                return Text(
                  otherUser.isOnline ? context.tr('online') : context.tr('offline'),
                  style: TextStyle(fontSize: 12, color: otherUser.isOnline ? Colors.green : AppColors.textMuted),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
