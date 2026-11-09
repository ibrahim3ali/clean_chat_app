import 'package:clean_chat_app/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageToggleButton extends StatelessWidget {
  final Color? color;

  const LanguageToggleButton({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        final isArabic = locale.languageCode == 'ar';
        return TextButton.icon(
          onPressed: () => context.read<LocaleCubit>().toggleLocale(),
          icon: Icon(
            Icons.language_rounded,
            size: 20,
            color: color ?? AppColors.primary,
          ),
          label: Text(
            isArabic ? 'English' : 'العربية',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.primary,
            ),
          ),
        );
      },
    );
  }
}
