import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core.dart';
import '../../../../features.dart';

class UserProfileScreen extends StatelessWidget {
  final UserEntity user;
  final bool isCurrentUser;
  final UserEntity? currentUser;

  const UserProfileScreen({
    super.key,
    required this.user,
    required this.isCurrentUser,
    this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isCurrentUser
              ? context.tr('profile')
              : context.tr('contactInfo'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          if (isCurrentUser)
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: context.tr('settings'),
              onPressed: () => SettingsBottomSheet.show(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // 1. Avatar & Online Status Badge
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.storyRingGradient,
                    ),
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor:
                          isDark ? AppColors.darkBackground : Colors.white,
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          user.name.isNotEmpty
                              ? user.name.characters.first.toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: user.isOnline || isCurrentUser
                            ? AppColors.activeGreen
                            : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: surfaceColor,
                          width: 3.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. User Name & (You) badge
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    user.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                if (isCurrentUser) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      context.tr('you'),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),

            // Status Text (متصل الآن / غير متصل)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: user.isOnline || isCurrentUser
                        ? AppColors.activeGreen
                        : AppColors.textMuted,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  user.isOnline || isCurrentUser
                      ? context.tr('online')
                      : context.tr('offline'),
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: user.isOnline || isCurrentUser
                        ? AppColors.activeGreen
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. Quick Action Buttons (Only for Receiver / Contact)
            if (!isCurrentUser) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickAction(
                    context,
                    icon: Icons.chat_bubble_outline_rounded,
                    label: context.tr('sendMessage'),
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildQuickAction(
                    context,
                    icon: Icons.copy_rounded,
                    label: context.tr('email'),
                    color: const Color(0xFF0084FF),
                    onTap: () => _copyToClipboard(context, user.email),
                  ),
                  if (currentUser != null)
                    _buildQuickAction(
                      context,
                      icon: Icons.cleaning_services_rounded,
                      label: context.tr('clearChat'),
                      color: AppColors.error,
                      onTap: () {
                        final chatId = currentUser!.uid.compareTo(user.uid) < 0
                            ? '${currentUser!.uid}_${user.uid}'
                            : '${user.uid}_${currentUser!.uid}';
                        ClearChatDialog.show(
                          context,
                          onClear: (deleteForEveryone) {
                            context.read<ChatCubit>().clearChat(
                              chatId: chatId,
                              currentUserId: currentUser!.uid,
                              deleteForEveryone: deleteForEveryone,
                            );
                          },
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // 4. Account Details Card
            _buildSectionHeader(context, context.tr('accountInfo')),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor.withValues(alpha: 0.8), width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoTile(
                    context,
                    icon: Icons.alternate_email_rounded,
                    title: context.tr('email'),
                    value: user.email,
                    onCopy: () => _copyToClipboard(context, user.email),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 5. Settings Card (Only for Sender / Current User)
            if (isCurrentUser) ...[
              _buildSectionHeader(context, context.tr('settings')),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor.withValues(alpha: 0.8), width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.palette_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        context.tr('themeTitle'),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BlocBuilder<ThemeCubit, ThemeMode>(
                            builder: (context, mode) {
                              String label = context.tr('systemMode');
                              if (mode == ThemeMode.dark) {
                                label = context.tr('darkMode');
                              } else if (mode == ThemeMode.light) {
                                label = context.tr('lightMode');
                              }
                              return Text(
                                label,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: textSecondary,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: textSecondary,
                          ),
                        ],
                      ),
                      onTap: () => SettingsBottomSheet.show(context),
                    ),
                    Divider(
                      height: 1,
                      indent: 56,
                      color: borderColor.withValues(alpha: 0.6),
                    ),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0084FF).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.language_rounded,
                          color: Color(0xFF0084FF),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        context.tr('language'),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BlocBuilder<LocaleCubit, Locale>(
                            builder: (context, locale) {
                              return Text(
                                locale.languageCode == 'ar'
                                    ? 'العربية'
                                    : 'English',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: textSecondary,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: textSecondary,
                          ),
                        ],
                      ),
                      onTap: () => SettingsBottomSheet.show(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Logout Button
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => LogoutDialog.show(
                  context,
                  onConfirm: () => context.read<AuthCubit>().logout(),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.25),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.logout_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.tr('logout'),
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 96,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor.withValues(alpha: 0.8), width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onCopy,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: textSecondary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.copy_rounded,
              size: 18,
              color: textSecondary,
            ),
            tooltip: context.tr('copiedToClipboard'),
            onPressed: onCopy,
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr('copiedToClipboard')),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
