import 'package:flutter/material.dart';

/// User preferences and settings.
class PlayerSettings {
  final ThemeMode themeMode;
  final bool hapticsEnabled;
  final bool soundEnabled;
  final bool reducedMotion;
  final bool tutorialSeen;

  const PlayerSettings({
    this.themeMode = ThemeMode.system,
    this.hapticsEnabled = true,
    this.soundEnabled = true,
    this.reducedMotion = false,
    this.tutorialSeen = false,
  });

  PlayerSettings copyWith({
    ThemeMode? themeMode,
    bool? hapticsEnabled,
    bool? soundEnabled,
    bool? reducedMotion,
    bool? tutorialSeen,
  }) {
    return PlayerSettings(
      themeMode: themeMode ?? this.themeMode,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      tutorialSeen: tutorialSeen ?? this.tutorialSeen,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.name,
      'hapticsEnabled': hapticsEnabled,
      'soundEnabled': soundEnabled,
      'reducedMotion': reducedMotion,
      'tutorialSeen': tutorialSeen,
    };
  }

  factory PlayerSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PlayerSettings();

    final themeStr = json['themeMode'] as String? ?? 'system';
    final themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == themeStr,
      orElse: () => ThemeMode.system,
    );

    return PlayerSettings(
      themeMode: themeMode,
      hapticsEnabled: (json['hapticsEnabled'] as bool?) ?? true,
      soundEnabled: (json['soundEnabled'] as bool?) ?? true,
      reducedMotion: (json['reducedMotion'] as bool?) ?? false,
      tutorialSeen: (json['tutorialSeen'] as bool?) ?? false,
    );
  }
}
