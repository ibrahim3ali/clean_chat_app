import 'package:flutter/material.dart';

import '../../../../core.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.chat_bubble_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoAsset = isDark
        ? 'assets/images/app_logo_dark.png'
        : 'assets/images/app_logo.png';

    return Column(
      children: [
        Container(
          height: 84,
          width: 84,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? AppColors.secondary.withValues(alpha: 0.35)
                    : AppColors.primary.withValues(alpha: 0.25),
                blurRadius: isDark ? 20 : 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Image.asset(
                logoAsset,
                key: ValueKey(logoAsset),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: Icon(icon, size: 40, color: AppColors.primary),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
