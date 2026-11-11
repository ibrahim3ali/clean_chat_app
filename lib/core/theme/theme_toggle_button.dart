import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../localization/localization_extension.dart';
import 'theme_cubit.dart';
import 'theme_selection_bottom_sheet.dart';

class ThemeToggleButton extends StatelessWidget {
  final Color? color;

  const ThemeToggleButton({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, currentMode) {
        IconData icon;
        if (currentMode == ThemeMode.system) {
          icon = Icons.brightness_auto_rounded;
        } else if (currentMode == ThemeMode.dark) {
          icon = Icons.dark_mode_rounded;
        } else {
          icon = Icons.light_mode_rounded;
        }

        return IconButton(
          icon: Icon(icon, color: color),
          tooltip: context.tr('themeTitle'),
          onPressed: () => ThemeSelectionBottomSheet.show(context),
        );
      },
    );
  }
}
