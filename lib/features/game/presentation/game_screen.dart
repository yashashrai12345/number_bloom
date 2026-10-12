import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_tokens.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/empty_ad_slot.dart';
import '../../settings/application/settings_controller.dart';
import '../application/game_controller.dart';
import 'widgets/game_board.dart';
import 'widgets/game_over_overlay.dart';
import 'widgets/pause_overlay.dart';
import 'widgets/score_card.dart';
import 'widgets/tutorial_overlay.dart';
import 'widgets/win_overlay.dart';

/// The primary playable puzzle screen.
class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameControllerProvider);
    final gameController = ref.read(gameControllerProvider.notifier);
    final settings = ref.watch(settingsControllerProvider);
    final settingsController = ref.read(settingsControllerProvider.notifier);
    final adsService = ref.read(adsServiceProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (gameState.isPaused) {
          gameController.resume();
        } else if (!gameState.isGameOver) {
          gameController.pause();
        } else {
          Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Top navigation header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: BloomTokens.space16,
                      vertical: BloomTokens.space8,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                          tooltip: 'Main Menu',
                          onPressed: () async {
                            if (!gameState.isGameOver && gameState.score > 0) {
                              final confirm = await ConfirmDialog.show(
                                context,
                                title: 'Return to Menu?',
                                message: 'Your run is saved. You can continue anytime.',
                                confirmText: 'Return Home',
                                cancelText: 'Keep Playing',
                              );
                              if (confirm == true && context.mounted) {
                                Navigator.of(context).pop();
                              }
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                        const Expanded(
                          child: Text(
                            'Number Bloom',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, size: 24),
                          tooltip: 'Restart Garden',
                          onPressed: () async {
                            if (gameState.score > 0) {
                              final confirm = await ConfirmDialog.show(context);
                              if (confirm == true) {
                                gameController.startNewGame();
                              }
                            } else {
                              gameController.startNewGame();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.pause_rounded, size: 24),
                          tooltip: 'Pause Game',
                          onPressed: () => gameController.pause(),
                        ),
                      ],
                    ),
                  ),

                  // Score & Best Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: BloomTokens.space20,
                      vertical: BloomTokens.space8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ScoreCard(
                            title: 'Score',
                            score: gameState.score,
                            icon: Icons.local_florist_rounded,
                            isHighlight: true,
                          ),
                        ),
                        const SizedBox(width: BloomTokens.space12),
                        Expanded(
                          child: ScoreCard(
                            title: 'Best',
                            score: gameState.bestScore,
                            icon: Icons.emoji_events_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Board Area
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: BloomTokens.space20,
                            vertical: BloomTokens.space8,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: GameBoard(
                              board: gameState.board,
                              reducedMotion: settings.reducedMotion,
                              isInputLocked: gameState.isGameOver ||
                                  gameState.isPaused ||
                                  gameState.isAnimating ||
                                  !settings.tutorialSeen ||
                                  (gameState.hasWon && !gameState.winOverlayDismissed),
                              onMove: (dir) => gameController.makeMove(dir),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Reserved Non-intrusive Ad Banner Area
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: BannerAdSlot(),
                  ),
                ],
              ),

              // Tutorial Overlay (if not seen yet)
              if (!settings.tutorialSeen)
                TutorialOverlay(
                  onDismiss: () => settingsController.dismissTutorial(),
                ),

              // Pause Overlay
              if (gameState.isPaused)
                PauseOverlay(
                  onResume: () => gameController.resume(),
                  onRestart: () {
                    gameController.resume();
                    gameController.startNewGame();
                  },
                  onHome: () {
                    gameController.resume();
                    Navigator.of(context).pop();
                  },
                ),

              // Win Overlay (First reach of 2048)
              if (gameState.hasWon && !gameState.winOverlayDismissed)
                WinOverlay(
                  currentScore: gameState.score,
                  reducedMotion: settings.reducedMotion,
                  onContinue: () => gameController.continueAfterWin(),
                  onNewGame: () => gameController.startNewGame(),
                ),

              // Game Over Overlay
              if (gameState.isGameOver)
                GameOverOverlay(
                  finalScore: gameState.score,
                  bestScore: gameState.bestScore,
                  onPlayAgain: () {
                    adsService.showInterstitialIfEligible(
                      onComplete: () {
                        gameController.startNewGame();
                      },
                    );
                  },
                  onHome: () {
                    adsService.showInterstitialIfEligible(
                      onComplete: () {
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
