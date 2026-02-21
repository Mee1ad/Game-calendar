import 'package:flutter/material.dart';
import 'package:game_calendar/core/theme/app_theme.dart';
import 'package:game_calendar/features/home/presentation/pages/home_page.dart';

class GameCalendarApp extends StatelessWidget {
  const GameCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game Calendar',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const HomePage(),
    );
  }
}
