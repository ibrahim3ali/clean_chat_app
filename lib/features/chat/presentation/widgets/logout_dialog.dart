import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/localization_extension.dart';

class LogoutDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const LogoutDialog({super.key, required this.onConfirm});

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (_) => LogoutDialog(onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.tr('logout')),
      content: Text(context.tr('logoutConfirm')),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(context.tr('cancel')),
        ),
        TextButton(
          onPressed: () {
            context.pop();
            onConfirm();
          },
          child: Text(
            context.tr('confirm'),
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ],
    );
  }
}
