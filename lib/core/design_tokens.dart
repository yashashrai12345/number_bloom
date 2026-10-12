import 'package:flutter/material.dart';

/// Design tokens for Number Bloom.
///
/// Follows a botanic/bloom inspired aesthetic with high contrast,
/// calming earth/petal tones, and distinct progression for tile values.
class BloomTokens {
  // Spacing scale
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space28 = 28.0;
  static const double space32 = 32.0;

  // Corner radii
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 14.0;
  static const double radiusLarge = 20.0;
  static const double radiusXLarge = 28.0;

  // Animation durations
  static const Duration slideDuration = Duration(milliseconds: 140);
  static const Duration scalePopDuration = Duration(milliseconds: 160);
  static const Duration fastDuration = Duration(milliseconds: 100);

  // Light Theme Palette
  static const Color lightBg = Color(0xFFF9F7F2); // Warm parchment petal
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBoardBg = Color(0xFFE8E2D5); // Soft stone/moss
  static const Color lightEmptyCell = Color(0xFFDED6C7); // Pebble
  static const Color lightTextPrimary = Color(0xFF2C332D);
  static const Color lightTextSecondary = Color(0xFF6B726C);
  static const Color lightAccent = Color(0xFF2E7D52); // Forest emerald
  static const Color lightAccentBloom = Color(0xFFE26D5C); // Coral blossom

  // Dark Theme Palette
  static const Color darkBg = Color(0xFF141916); // Night garden
  static const Color darkSurface = Color(0xFF1D2420);
  static const Color darkBoardBg = Color(0xFF181F1A);
  static const Color darkEmptyCell = Color(0xFF242E27);
  static const Color darkTextPrimary = Color(0xFFEFF5F0);
  static const Color darkTextSecondary = Color(0xFF8F9E93);
  static const Color darkAccent = Color(0xFF4EBA87); // Luminous jade
  static const Color darkAccentBloom = Color(0xFFF07865); // Warm petal

  /// Returns styling parameters for a given tile value and brightness mode.
  static TileStyle getTileStyle(int value, bool isDark) {
    if (value <= 0) {
      return TileStyle(
        backgroundColor: isDark ? darkEmptyCell : lightEmptyCell,
        textColor: Colors.transparent,
      );
    }

    switch (value) {
      case 2:
        return TileStyle(
          backgroundColor: isDark ? const Color(0xFF2A362E) : const Color(0xFFEEE4D8),
          textColor: isDark ? const Color(0xFFDDE7DF) : const Color(0xFF4E463F),
        );
      case 4:
        return TileStyle(
          backgroundColor: isDark ? const Color(0xFF334538) : const Color(0xFFECE0C6),
          textColor: isDark ? const Color(0xFFE2EBE3) : const Color(0xFF4A423B),
        );
      case 8:
        return const TileStyle(
          backgroundColor: Color(0xFFF2B179),
          textColor: Colors.white,
        );
      case 16:
        return const TileStyle(
          backgroundColor: Color(0xFFF59563),
          textColor: Colors.white,
        );
      case 32:
        return const TileStyle(
          backgroundColor: Color(0xFFF67C5F),
          textColor: Colors.white,
        );
      case 64:
        return const TileStyle(
          backgroundColor: Color(0xFFE75C41),
          textColor: Colors.white,
        );
      case 128:
        return const TileStyle(
          backgroundColor: Color(0xFFEDCF72),
          textColor: Colors.white,
          isGlow: true,
        );
      case 256:
        return const TileStyle(
          backgroundColor: Color(0xFFEDCC61),
          textColor: Colors.white,
          isGlow: true,
        );
      case 512:
        return const TileStyle(
          backgroundColor: Color(0xFF9C51E0),
          textColor: Colors.white,
          isGlow: true,
        );
      case 1024:
        return const TileStyle(
          backgroundColor: Color(0xFF6C42EC),
          textColor: Colors.white,
          isGlow: true,
        );
      case 2048:
        return const TileStyle(
          backgroundColor: Color(0xFF10B981),
          textColor: Colors.white,
          isGlow: true,
          isSpecialBloom: true,
        );
      default:
        // Above 2048
        return const TileStyle(
          backgroundColor: Color(0xFF3B2E6E),
          textColor: Colors.white,
          isGlow: true,
          isSpecialBloom: true,
        );
    }
  }
}

/// Visual style configuration for a tile on the board.
class TileStyle {
  final Color backgroundColor;
  final Color textColor;
  final bool isGlow;
  final bool isSpecialBloom;

  const TileStyle({
    required this.backgroundColor,
    required this.textColor,
    this.isGlow = false,
    this.isSpecialBloom = false,
  });
}
