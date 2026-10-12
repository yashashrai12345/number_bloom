import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_tokens.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/empty_ad_slot.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../game/application/game_controller.dart';
import '../../game/presentation/game_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../stats/presentation/stats_dialog.dart';

/// The welcoming Home screen showcasing the Number Bloom brand,
/// record achievements, and intuitive Start / Continue actions.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameControllerProvider);
    final gameController = ref.read(gameControllerProvider.notifier);
    final stats = ref.watch(gameStatsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hasActiveGame = gameState.score > 0 && !gameState.isGameOver;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Settings
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: BloomTokens.space16,
                vertical: BloomTokens.space8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.bar_chart_rounded, size: 26),
                    tooltip: 'Garden Statistics',
                    onPressed: () {
                      StatsDialog.show(
                        context,
                        stats: stats,
                        bestScore: gameState.bestScore,
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, size: 24),
                    tooltip: 'Settings',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Main Hero Area
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: BloomTokens.space24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Botanic Bloom Logo Badge
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF233B2E), const Color(0xFF14241B)]
                                : [const Color(0xFFE8F6ED), const Color(0xFFDFEFE5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? BloomTokens.darkAccent : BloomTokens.lightAccent,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? BloomTokens.darkAccent : BloomTokens.lightAccent)
                                  .withValues(alpha: 0.3),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.spa_rounded,
                          size: 56,
                          color: isDark ? BloomTokens.darkAccent : BloomTokens.lightAccent,
                        ),
                      ),
                      const SizedBox(height: BloomTokens.space20),

                      // Brand Titles
                      Text(
                        'Number Bloom',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: isDark ? BloomTokens.darkTextPrimary : BloomTokens.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Merge Puzzle',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2.5,
                          color: isDark ? BloomTokens.darkAccent : BloomTokens.lightAccent,
                        ),
                      ),
                      const SizedBox(height: BloomTokens.space28),

                      // Best Score Badge Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? BloomTokens.darkSurface : BloomTokens.lightSurface,
                          borderRadius: BorderRadius.circular(BloomTokens.radiusLarge),
                          border: Border.all(
                            color: isDark ? const Color(0xFF2C3831) : const Color(0xFFE5DFD4),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.emoji_events_rounded,
                              size: 22,
                              color: Color(0xFFF2B179),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Best Score:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? BloomTokens.darkTextSecondary
                                    : BloomTokens.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${gameState.bestScore}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? BloomTokens.darkTextPrimary
                                    : BloomTokens.lightTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: BloomTokens.space32),

                      // Primary Buttons
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (hasActiveGame) ...[
                              PrimaryButton(
                                label: 'Continue Garden',
                                icon: Icons.play_arrow_rounded,
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const GameScreen(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 14),
                            ],
                            PrimaryButton(
                              label: 'New Garden',
                              icon: Icons.add_rounded,
                              isSecondary: hasActiveGame,
                              onPressed: () async {
                                if (hasActiveGame) {
                                  final confirm = await ConfirmDialog.show(context);
                                  if (confirm != true) return;
                                }
                                gameController.startNewGame();
                                if (context.mounted) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const GameScreen(),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Banner Ad Slot
            const Padding(
              padding: EdgeInsets.only(bottom: 6.0),
              child: BannerAdSlot(),
            ),
          ],
        ),
      ),
    );
  }
}
