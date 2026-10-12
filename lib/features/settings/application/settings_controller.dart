import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/persistence/local_store.dart';
import '../domain/player_settings.dart';

final localStoreProvider = Provider<LocalStore>((ref) {
  throw UnimplementedError('localStoreProvider must be overridden in ProviderScope');
});

final settingsControllerProvider =
    NotifierProvider<SettingsController, PlayerSettings>(SettingsController.new);

class SettingsController extends Notifier<PlayerSettings> {
  @override
  PlayerSettings build() {
    final store = ref.watch(localStoreProvider);
    return store.loadSnapshot().settings;
  }

  void updateTheme(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _persist();
  }

  void toggleHaptics(bool enabled) {
    state = state.copyWith(hapticsEnabled: enabled);
    _persist();
  }

  void toggleSound(bool enabled) {
    state = state.copyWith(soundEnabled: enabled);
    _persist();
  }

  void toggleReducedMotion(bool enabled) {
    state = state.copyWith(reducedMotion: enabled);
    _persist();
  }

  void dismissTutorial() {
    state = state.copyWith(tutorialSeen: true);
    _persist();
  }

  void _persist() {
    final store = ref.read(localStoreProvider);
    final snapshot = store.loadSnapshot();
    store.saveSnapshot(
      activeGame: snapshot.activeGame,
      bestScore: snapshot.bestScore,
      stats: snapshot.stats,
      settings: state,
    );
  }
}
