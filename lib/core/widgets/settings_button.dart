import 'package:flutter/material.dart';

import '../../core.dart';

class SettingsButton extends StatelessWidget {
  final bool isAuthScreen;
  final Color? color;

  const SettingsButton({
    super.key,
    this.isAuthScreen = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = color ??
        (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary);

    return IconButton(
      icon: Icon(
        Icons.settings_outlined,
        color: iconColor,
        size: 23,
      ),
      tooltip: context.tr('settings'),
      onPressed: () => SettingsBottomSheet.show(
        context,
        isAuthScreen: isAuthScreen,
      ),
    );
  }
}
