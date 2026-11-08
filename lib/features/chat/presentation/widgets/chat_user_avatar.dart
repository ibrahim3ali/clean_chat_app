import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

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
        CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          child: Text(
            letter,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: radius * 0.75,
            ),
          ),
        ),
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
