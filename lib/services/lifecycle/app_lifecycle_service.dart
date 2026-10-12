import 'package:flutter/widgets.dart';
import '../../features/game/domain/game_state.dart';
import '../../features/settings/domain/player_settings.dart';
import '../persistence/local_store.dart';

/// Monitors application lifecycle state transitions (backgrounding, pausing)
/// to guarantee data integrity across process pauses.
class AppLifecycleService with WidgetsBindingObserver {
  final LocalStore store;
  final GameState Function() getGameState;
  final PlayerSettings Function() getSettings;

  AppLifecycleService({
    required this.store,
    required this.getGameState,
    required this.getSettings,
  });

  void start() {
    WidgetsBinding.instance.addObserver(this);
  }

  void stop() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      final currentSnapshot = store.loadSnapshot();
      final currentGame = getGameState();
      if (!currentGame.isGameOver) {
        store.saveSnapshot(
          activeGame: currentGame,
          bestScore: currentGame.bestScore,
          stats: currentSnapshot.stats,
          settings: getSettings(),
        );
      }
    }
  }
}
