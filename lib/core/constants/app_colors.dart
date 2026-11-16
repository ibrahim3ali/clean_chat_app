import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Vibrant Messenger & Instagram Primary Palette
  static const Color primary = Color(0xFF7000FF);
  static const Color primaryLight = Color(0xFFF3E8FF);
  static const Color primaryDark = Color(0xFF4C00B0);
  static const Color secondary = Color(0xFFFF2E93);
  static const Color accent = Color(0xFF00D2FF);

  static const Color background = Color(0xFFF8F9FE);
  static const Color surface = Colors.white;

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  static const Color sentMessage = Color(0xFF7000FF);
  static const Color receivedMessage = Color(0xFFF1F5F9);

  static const Color error = Color(0xFFEF4444);
  static const Color border = Color(0xFFE2E8F0);
  static const Color activeGreen = Color(0xFF10B981);

  // Modern Signature Gradients (Instagram & Messenger style)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0084FF),
      Color(0xFFA824FF),
      Color(0xFFFF2E93),
    ],
  );

  static const LinearGradient sentBubbleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6366F1),
      Color(0xFF9333EA),
      Color(0xFFE11D48),
    ],
  );

  static const LinearGradient storyRingGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFFFBAA47),
      Color(0xFFD91A46),
      Color(0xFFA60F93),
    ],
  );

  static const LinearGradient fabGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7000FF),
      Color(0xFFFF2E93),
    ],
  );

  // Dark Theme Palette (Deep Midnight OLED)
  static const Color darkBackground = Color(0xFF0B0E14);
  static const Color darkSurface = Color(0xFF151A26);
  static const Color darkSurfaceVariant = Color(0xFF1F2739);
  static const Color darkBorder = Color(0xFF263249);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);
  static const Color darkReceivedMessage = Color(0xFF1E2638);
}
