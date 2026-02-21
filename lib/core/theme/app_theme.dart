import 'package:flutter/material.dart';
import 'package:game_calendar/core/theme/app_theme_extension.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        extensions: [AppThemeExtension.light],
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        extensions: [AppThemeExtension.dark],
      );
}
