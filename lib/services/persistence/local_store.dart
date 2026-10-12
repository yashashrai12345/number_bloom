import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/game/domain/game_state.dart';
import '../../features/settings/domain/player_settings.dart';

/// Container for all locally persisted data.
class SavedSnapshot {
  final int schemaVersion;
  final GameState? activeGame;
  final int bestScore;
  final GameStats stats;
  final PlayerSettings settings;
  final DateTime updatedAt;

  const SavedSnapshot({
    required this.schemaVersion,
    required this.activeGame,
    required this.bestScore,
    required this.stats,
    required this.settings,
    required this.updatedAt,
  });

  factory SavedSnapshot.empty() {
    return SavedSnapshot(
      schemaVersion: 1,
      activeGame: null,
      bestScore: 0,
      stats: const GameStats(),
      settings: const PlayerSettings(),
      updatedAt: DateTime.now(),
    );
  }
}

/// Local persistence service managing game snapshots, preferences, and recovery.
class LocalStore {
  static const String keySnapshot = 'number_bloom_save_v1';
  static const int currentSchemaVersion = 1;

  final SharedPreferences? _prefs;

  LocalStore([this._prefs]);

  static Future<LocalStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStore(prefs);
  }

  /// Saves the complete game snapshot to local storage.
  Future<bool> saveSnapshot({
    GameState? activeGame,
    required int bestScore,
    required GameStats stats,
    required PlayerSettings settings,
  }) async {
    if (_prefs == null) return false;
    try {
      final map = {
        'schemaVersion': currentSchemaVersion,
        'currentGame': (activeGame != null && !activeGame.isGameOver)
            ? activeGame.toJson()
            : null,
        'bestScore': bestScore,
        'stats': stats.toJson(),
        'settings': settings.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      return await _prefs.setString(keySnapshot, jsonEncode(map));
    } catch (_) {
      return false;
    }
  }

  /// Loads and validates the saved snapshot.
  /// Gracefully recovers on corrupt or missing data without throwing.
  SavedSnapshot loadSnapshot() {
    if (_prefs == null) return SavedSnapshot.empty();

    final rawJson = _prefs.getString(keySnapshot);
    if (rawJson == null || rawJson.isEmpty) {
      return SavedSnapshot.empty();
    }

    try {
      final dynamic decoded = jsonDecode(rawJson);
      if (decoded is! Map<String, dynamic>) {
        return SavedSnapshot.empty();
      }

      final schemaVersion = (decoded['schemaVersion'] as num?)?.toInt() ?? 0;
      final bestScore = (decoded['bestScore'] as num?)?.toInt() ?? 0;
      final stats = GameStats.fromJson(decoded['stats'] as Map<String, dynamic>?);
      final settings = PlayerSettings.fromJson(decoded['settings'] as Map<String, dynamic>?);

      DateTime updatedAt;
      try {
        updatedAt = DateTime.parse(decoded['updatedAt'] as String);
      } catch (_) {
        updatedAt = DateTime.now();
      }

      // If schema version is unsupported or mismatched, salvage bestScore, stats, and settings
      if (schemaVersion != currentSchemaVersion) {
        return SavedSnapshot(
          schemaVersion: currentSchemaVersion,
          activeGame: null,
          bestScore: bestScore,
          stats: stats,
          settings: settings,
          updatedAt: updatedAt,
        );
      }

      GameState? activeGame;
      final currentMap = decoded['currentGame'] as Map<String, dynamic>?;
      if (currentMap != null) {
        activeGame = GameState.fromJson(currentMap, bestScore);
      }

      return SavedSnapshot(
        schemaVersion: schemaVersion,
        activeGame: activeGame,
        bestScore: bestScore,
        stats: stats,
        settings: settings,
        updatedAt: updatedAt,
      );
    } catch (_) {
      // Corrupt data fallback
      return SavedSnapshot.empty();
    }
  }

  /// Clears saved active game run (e.g. after Game Over or when user starts new game).
  Future<void> clearActiveGame({
    required int bestScore,
    required GameStats stats,
    required PlayerSettings settings,
  }) async {
    await saveSnapshot(
      activeGame: null,
      bestScore: bestScore,
      stats: stats,
      settings: settings,
    );
  }
}
