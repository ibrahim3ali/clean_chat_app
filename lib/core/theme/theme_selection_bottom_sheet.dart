import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants/app_colors.dart';
import '../localization/localization_extension.dart';
import 'theme_cubit.dart';

class ThemeSelectionBottomSheet extends StatelessWidget {
  const ThemeSelectionBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const ThemeSelectionBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentMode = context.watch<ThemeCubit>().state;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                context.tr('themeTitle'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildOption(
              context,
              mode: ThemeMode.system,
              title: context.tr('systemMode'),
              subtitle: context.tr('systemModeDesc'),
              icon: Icons.brightness_auto_rounded,
              isSelected: currentMode == ThemeMode.system,
            ),
            _buildOption(
              context,
              mode: ThemeMode.light,
              title: context.tr('lightMode'),
              subtitle: context.tr('lightModeDesc'),
              icon: Icons.light_mode_rounded,
              isSelected: currentMode == ThemeMode.light,
            ),
            _buildOption(
              context,
              mode: ThemeMode.dark,
              title: context.tr('darkMode'),
              subtitle: context.tr('darkModeDesc'),
              icon: Icons.dark_mode_rounded,
              isSelected: currentMode == ThemeMode.dark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required ThemeMode mode,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = AppColors.primary;
    final unselectedBg = Colors.transparent;
    final selectedBg = selectedColor.withValues(alpha: isDark ? 0.2 : 0.1);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? selectedBg : unselectedBg,
        borderRadius: BorderRadius.circular(16),
        border: isSelected
            ? Border.all(color: selectedColor.withValues(alpha: 0.5), width: 1.5)
            : null,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: isSelected
              ? selectedColor
              : (isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade100),
          child: Icon(
            icon,
            size: 20,
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 15,
            color: isSelected
                ? selectedColor
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
            : null,
        onTap: () {
          context.read<ThemeCubit>().changeTheme(mode);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
