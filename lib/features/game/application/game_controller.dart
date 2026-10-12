import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/ads/ads_service.dart';
import '../../settings/application/settings_controller.dart';
import '../domain/game_rules.dart';
import '../domain/game_state.dart';
import '../domain/move_direction.dart';
import '../domain/random_provider.dart';

final randomProvider = Provider<RandomProvider>((ref) => DefaultRandomProvider());

final adsServiceProvider = Provider<AdsService>((ref) => AdsService());

final gameStatsProvider =
    NotifierProvider<GameStatsNotifier, GameStats>(GameStatsNotifier.new);

class GameStatsNotifier extends Notifier<GameStats> {
  @override
  GameStats build() {
    final store = ref.watch(localStoreProvider);
    return store.loadSnapshot().stats;
  }

  void recordGamePlayed() {
    state = state.copyWith(gamesPlayed: state.gamesPlayed + 1);
    _persist();
  }

  void recordMerges(int count, int highestBoardTile) {
    state = state.copyWith(
      totalMerges: state.totalMerges + count,
      highestTile: math.max(state.highestTile, highestBoardTile),
    );
    _persist();
  }

  void _persist() {
    final store = ref.read(localStoreProvider);
    final snapshot = store.loadSnapshot();
    store.saveSnapshot(
      activeGame: snapshot.activeGame,
      bestScore: snapshot.bestScore,
      stats: state,
      settings: snapshot.settings,
    );
  }
}

final gameControllerProvider =
    NotifierProvider<GameController, GameState>(GameController.new);

class GameController extends Notifier<GameState> {
  @override
  GameState build() {
    final store = ref.watch(localStoreProvider);
    final rng = ref.watch(randomProvider);
    final snapshot = store.loadSnapshot();

    return snapshot.activeGame ??
        GameState.initial(
          board: GameRules.createInitialBoard(rng),
          bestScore: snapshot.bestScore,
        );
  }

  /// Starts a fresh game run. Resets score & moveCount, preserves bestScore.
  void startNewGame() {
    final rng = ref.read(randomProvider);
    final newBoard = GameRules.createInitialBoard(rng);
    final newState = GameState.initial(
      board: newBoard,
      bestScore: state.bestScore,
    );
    state = newState;
    ref.read(gameStatsProvider.notifier).recordGamePlayed();
    _persist(newState);
  }

  /// Resumes from saved active game if available.
  void resumeGame() {
    final store = ref.read(localStoreProvider);
    final snapshot = store.loadSnapshot();
    if (snapshot.activeGame != null && !snapshot.activeGame!.isGameOver) {
      state = snapshot.activeGame!;
    } else {
      startNewGame();
    }
  }

  /// Executes a directional swipe move.
  /// Locks input during move processing and commit.
  Future<bool> makeMove(MoveDirection direction) async {
    // Ignore gestures if game is over, paused, or currently animating
    if (state.isGameOver || state.isPaused || state.isAnimating) {
      return false;
    }

    // Step 1: Calculate deterministic slide and merge
    final moveResult = GameRules.applyMove(state.board, direction);
    if (!moveResult.changed) {
      // Invalid move: do not change score, spawn, or increment moveCount
      return false;
    }

    // Lock input
    state = state.copyWith(isAnimating: true);

    // Provide haptic feedback if merges occurred and haptics enabled
    if (moveResult.mergesCount > 0) {
      final settings = ref.read(settingsControllerProvider);
      if (settings.hapticsEnabled) {
        HapticFeedback.lightImpact();
      }
    }

    // Step 2: Spawn new tile in an empty cell
    final rng = ref.read(randomProvider);
    final updatedBoard = GameRules.spawnTile(moveResult.board, rng);

    // Step 3: Update score & best score
    final newScore = state.score + moveResult.scoreGained;
    final newBestScore = math.max(state.bestScore, newScore);
    final newMoveCount = state.moveCount + 1;

    // Step 4: Check win condition
    bool hasWon = state.hasWon;
    if (!hasWon && GameRules.hasTileAtLeast(updatedBoard, GameRules.winThreshold)) {
      hasWon = true;
    }

    // Step 5: Check game over condition
    final isGameOver = GameRules.isGameOver(updatedBoard);
    if (isGameOver) {
      ref.read(adsServiceProvider).recordGameEnded();
    }

    // Update stats
    ref.read(gameStatsProvider.notifier).recordMerges(
          moveResult.mergesCount,
          updatedBoard.highestTile,
        );

    final nextState = state.copyWith(
      board: updatedBoard,
      score: newScore,
      bestScore: newBestScore,
      moveCount: newMoveCount,
      hasWon: hasWon,
      isGameOver: isGameOver,
      isAnimating: false,
    );

    state = nextState;

    // Step 6: Commit state immediately
    _persist(nextState);

    return true;
  }

  /// Dismisses win overlay and allows player to continue beyond 2048.
  void continueAfterWin() {
    final nextState = state.copyWith(winOverlayDismissed: true);
    state = nextState;
    _persist(nextState);
  }

  /// Pauses active game.
  void pause() {
    state = state.copyWith(isPaused: true);
  }

  /// Resumes paused game.
  void resume() {
    state = state.copyWith(isPaused: false);
  }

  void _persist(GameState currentState) {
    final store = ref.read(localStoreProvider);
    final snapshot = store.loadSnapshot();
    store.saveSnapshot(
      activeGame: currentState,
      bestScore: currentState.bestScore,
      stats: snapshot.stats,
      settings: snapshot.settings,
    );
  }
}
