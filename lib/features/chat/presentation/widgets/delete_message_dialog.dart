import 'package:flutter/material.dart';

import '../../../../core.dart';

class DeleteMessageDialog extends StatelessWidget {
  final bool isMe;
  final Function(bool deleteForEveryone) onDelete;

  const DeleteMessageDialog({
    super.key,
    required this.isMe,
    required this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    required bool isMe,
    required Function(bool deleteForEveryone) onDelete,
  }) {
    return showDialog(
      context: context,
      builder: (_) => DeleteMessageDialog(isMe: isMe, onDelete: onDelete),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.delete_outline_rounded, color: AppColors.error),
          const SizedBox(width: 8),
          Text(context.tr('deleteMessage')),
        ],
      ),
      content: Text(
        context.tr('deleteMessageConfirm'),
        style: const TextStyle(fontSize: 14),
      ),
      actionsAlignment: MainAxisAlignment.end,
      actionsOverflowDirection: VerticalDirection.down,
      actions: [
        if (isMe)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete(true);
            },
            child: Text(
              context.tr('deleteForEveryone'),
              style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDelete(false);
          },
          child: Text(context.tr('deleteForMe')),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            context.tr('cancel'),
            style: const TextStyle(color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}
