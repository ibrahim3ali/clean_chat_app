import 'package:flutter/material.dart';

import '../../../../core.dart';

class ClearChatDialog extends StatelessWidget {
  final Function(bool deleteForEveryone) onClear;

  const ClearChatDialog({super.key, required this.onClear});

  static Future<void> show(
    BuildContext context, {
    required Function(bool deleteForEveryone) onClear,
  }) {
    return showDialog(
      context: context,
      builder: (_) => ClearChatDialog(onClear: onClear),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.cleaning_services_rounded, color: AppColors.error),
          const SizedBox(width: 8),
          Text(context.tr('clearChat')),
        ],
      ),
      content: Text(
        context.tr('clearChatConfirm'),
        style: const TextStyle(fontSize: 14),
      ),
      actionsAlignment: MainAxisAlignment.end,
      actionsOverflowDirection: VerticalDirection.down,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onClear(true);
          },
          child: Text(
            context.tr('clearForEveryone'),
            style: const TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onClear(false);
          },
          child: Text(context.tr('clearForMe')),
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
