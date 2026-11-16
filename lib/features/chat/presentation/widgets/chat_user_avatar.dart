import 'package:flutter/material.dart';

import '../../../../core.dart';

class ChatUserAvatar extends StatelessWidget {
  final String name;
  final bool isOnline;
  final double radius;

  const ChatUserAvatar({
    super.key,
    required this.name,
    this.isOnline = false,
    this.radius = 26,
  });

  @override
  Widget build(BuildContext context) {
    final letter = name.isNotEmpty ? name.characters.first.toUpperCase() : '?';

    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(isOnline ? 2.5 : 0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isOnline ? AppColors.storyRingGradient : null,
          ),
          child: Container(
            padding: EdgeInsets.all(isOnline ? 2.0 : 0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: CircleAvatar(
              radius: radius,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: Text(
                letter,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: radius * 0.72,
                ),
              ),
            ),
          ),
        ),
        if (isOnline)
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.activeGreen,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.activeGreen.withValues(alpha: 0.4),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
