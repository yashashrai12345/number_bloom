import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_bloom/features/game/domain/board.dart';
import 'package:number_bloom/features/game/domain/game_state.dart';
import 'package:number_bloom/features/settings/domain/player_settings.dart';
import 'package:number_bloom/services/persistence/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Persistence & LocalStore recovery (PRD Section 7.2, 7.3 & AC-OFF-05)', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Saves and loads valid game snapshot correctly', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = LocalStore(prefs);

      final board = Board.fromMatrix([
        [2, 4, 8, 16],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      final state = GameState(
        board: board,
        score: 48,
        bestScore: 120,
        moveCount: 8,
        hasWon: false,
        winOverlayDismissed: false,
        isGameOver: false,
      );
      const stats = GameStats(gamesPlayed: 3, totalMerges: 12, highestTile: 64);
      const settings = PlayerSettings(hapticsEnabled: false, soundEnabled: true);

      await store.saveSnapshot(
        activeGame: state,
        bestScore: 120,
        stats: stats,
        settings: settings,
      );

      final snapshot = store.loadSnapshot();
      expect(snapshot.schemaVersion, equals(1));
      expect(snapshot.bestScore, equals(120));
      expect(snapshot.stats.gamesPlayed, equals(3));
      expect(snapshot.settings.hapticsEnabled, isFalse);
      expect(snapshot.activeGame, isNotNull);
      expect(snapshot.activeGame!.score, equals(48));
      expect(snapshot.activeGame!.board.get(0, 0), equals(2));
      expect(snapshot.activeGame!.board.get(0, 3), equals(16));
    });

    test('AC-OFF-05: Corrupt JSON payload recovers gracefully to default state without crashing', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(LocalStore.keySnapshot, '{ invalid json garbage ::: 123');

      final store = LocalStore(prefs);
      final snapshot = store.loadSnapshot();

      expect(snapshot.schemaVersion, equals(1));
      expect(snapshot.activeGame, isNull);
      expect(snapshot.bestScore, equals(0));
    });

    test('AC-OFF-05: Schema version mismatch salvages bestScore and settings', () async {
      final prefs = await SharedPreferences.getInstance();
      final oldSave = {
        'schemaVersion': 99, // unsupported future/old version
        'currentGame': {'score': 500},
        'bestScore': 1500,
        'stats': {'gamesPlayed': 10},
        'settings': {'hapticsEnabled': false},
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await prefs.setString(LocalStore.keySnapshot, jsonEncode(oldSave));

      final store = LocalStore(prefs);
      final snapshot = store.loadSnapshot();

      expect(snapshot.bestScore, equals(1500));
      expect(snapshot.stats.gamesPlayed, equals(10));
      expect(snapshot.settings.hapticsEnabled, isFalse);
      expect(snapshot.activeGame, isNull); // Discarded invalid board structure safely
    });

    test('Missing fields in save data use safe defaults', () async {
      final prefs = await SharedPreferences.getInstance();
      final partialSave = {
        'schemaVersion': 1,
        'bestScore': 80,
      };
      await prefs.setString(LocalStore.keySnapshot, jsonEncode(partialSave));

      final store = LocalStore(prefs);
      final snapshot = store.loadSnapshot();

      expect(snapshot.bestScore, equals(80));
      expect(snapshot.activeGame, isNull);
      expect(snapshot.stats.gamesPlayed, equals(0));
      expect(snapshot.settings.hapticsEnabled, isTrue);
    });

    test('Preserves isGameOver flag in saved game snapshot (PRD Section 7.2)', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = LocalStore(prefs);

      final board = Board.fromMatrix([
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 2],
      ]);
      final gameOverState = GameState(
        board: board,
        score: 120,
        bestScore: 120,
        moveCount: 25,
        hasWon: false,
        winOverlayDismissed: false,
        isGameOver: true,
      );

      await store.saveSnapshot(
        activeGame: gameOverState,
        bestScore: 120,
        stats: const GameStats(),
        settings: const PlayerSettings(),
      );

      final snapshot = store.loadSnapshot();
      expect(snapshot.activeGame, isNotNull);
      expect(snapshot.activeGame!.isGameOver, isTrue);
      expect(snapshot.activeGame!.score, equals(120));
    });
  });
}
