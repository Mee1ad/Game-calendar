import 'package:flutter/material.dart';

@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color cardBackground;
  final Color shimmerBase;
  final Color shimmerHighlight;

  const AppThemeExtension({
    required this.cardBackground,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  static AppThemeExtension get light => AppThemeExtension(
        cardBackground: Colors.white,
        shimmerBase: Colors.grey.shade300,
        shimmerHighlight: Colors.grey.shade100,
      );

  static AppThemeExtension get dark => AppThemeExtension(
        cardBackground: const Color(0xFF1E1E2E),
        shimmerBase: Colors.grey.shade800,
        shimmerHighlight: Colors.grey.shade700,
      );

  @override
  AppThemeExtension copyWith({
    Color? cardBackground,
    Color? shimmerBase,
    Color? shimmerHighlight,
  }) =>
      AppThemeExtension(
        cardBackground: cardBackground ?? this.cardBackground,
        shimmerBase: shimmerBase ?? this.shimmerBase,
        shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      );

  @override
  AppThemeExtension lerp(
    covariant ThemeExtension<AppThemeExtension>? other,
    double t,
  ) =>
      this;
}
