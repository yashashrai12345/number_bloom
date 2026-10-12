import 'package:flutter/material.dart';
import 'design_tokens.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: BloomTokens.lightBg,
      colorScheme: const ColorScheme.light(
        primary: BloomTokens.lightAccent,
        secondary: BloomTokens.lightAccentBloom,
        surface: BloomTokens.lightSurface,
        onSurface: BloomTokens.lightTextPrimary,
      ),
    );

    return base.copyWith(
      cardTheme: CardThemeData(
        color: BloomTokens.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BloomTokens.radiusMedium),
          side: const BorderSide(color: Color(0xFFEBE6DC), width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: BloomTokens.lightSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BloomTokens.radiusLarge),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: BloomTokens.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: BloomTokens.darkAccent,
        secondary: BloomTokens.darkAccentBloom,
        surface: BloomTokens.darkSurface,
        onSurface: BloomTokens.darkTextPrimary,
      ),
    );

    return base.copyWith(
      cardTheme: CardThemeData(
        color: BloomTokens.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BloomTokens.radiusMedium),
          side: const BorderSide(color: Color(0xFF2B3630), width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: BloomTokens.darkSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BloomTokens.radiusLarge),
        ),
      ),
    );
  }
}
