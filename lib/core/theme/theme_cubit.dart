import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _prefKey = 'selected_theme_mode';

  ThemeCubit() : super(ThemeMode.system) {
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(_prefKey);
    if (mode == 'dark') {
      emit(ThemeMode.dark);
    } else if (mode == 'light') {
      emit(ThemeMode.light);
    } else {
      emit(ThemeMode.system);
    }
  }

  Future<void> changeTheme(ThemeMode mode) async {
    if (state == mode) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, mode.name);
    emit(mode);
  }

  void toggleTheme(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    changeTheme(isDark ? ThemeMode.light : ThemeMode.dark);
  }
}
