import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_bloom/core/app_theme.dart';
import 'package:number_bloom/features/game/application/game_controller.dart';
import 'package:number_bloom/features/game/domain/board.dart';
import 'package:number_bloom/features/game/domain/game_state.dart';
import 'package:number_bloom/features/game/presentation/game_screen.dart';
import 'package:number_bloom/features/settings/application/settings_controller.dart';
import 'package:number_bloom/features/settings/domain/player_settings.dart';
import 'package:number_bloom/services/ads/ads_service.dart';
import 'package:number_bloom/services/persistence/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('GameScreen displays score cards, board, and tutorial dismissal', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final store = LocalStore(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStoreProvider.overrideWithValue(store),
          adsServiceProvider.overrideWithValue(AdsService()),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const GameScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title and Score cards exist
    expect(find.text('Number Bloom'), findsWidgets);
    expect(find.text('SCORE'), findsOneWidget);
    expect(find.text('BEST'), findsOneWidget);

    // Initial state has tutorial visible
    expect(find.text('How to Play'), findsOneWidget);
    expect(find.text('Got it, Let\'s Play!'), findsOneWidget);

    // Tap dismiss tutorial
    await tester.tap(find.text('Got it, Let\'s Play!'));
    await tester.pumpAndSettle();

    // Tutorial is dismissed
    expect(find.text('How to Play'), findsNothing);

    // Pause button exists
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);

    // Tap pause button
    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pumpAndSettle();

    // Pause overlay opens
    expect(find.text('Paused'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);

    // Tap Resume
    await tester.tap(find.text('Resume'));
    await tester.pumpAndSettle();

    // Pause overlay dismissed
    expect(find.text('Paused'), findsNothing);
  });

  testWidgets('GameScreen renders win overlay when 2048 is reached and allows continue', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final store = LocalStore(prefs);

    // Prepopulate store with tutorial seen and board with 2048 tile
    final winningBoard = Board.fromMatrix([
      [2048, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ]);
    final winState = GameState(
      board: winningBoard,
      score: 2048,
      bestScore: 2048,
      moveCount: 15,
      hasWon: true,
      winOverlayDismissed: false,
      isGameOver: false,
    );
    await store.saveSnapshot(
      activeGame: winState,
      bestScore: 2048,
      stats: const GameStats(),
      settings: const PlayerSettings(tutorialSeen: true),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStoreProvider.overrideWithValue(store),
          adsServiceProvider.overrideWithValue(AdsService()),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const GameScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Win overlay is displayed
    expect(find.text('Continue Playing'), findsOneWidget);

    // Tap Continue Playing
    await tester.tap(find.text('Continue Playing'));
    await tester.pumpAndSettle();

    // Overlay is dismissed and board/scores display 2048
    expect(find.text('Continue Playing'), findsNothing);
    expect(find.text('2048'), findsWidgets);
  });
}
