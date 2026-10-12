import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';
import '../../../../shared/widgets/primary_button.dart';

/// Game Over overlay shown when no valid moves remain on the board.
class GameOverOverlay extends StatelessWidget {
  final int finalScore;
  final int bestScore;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  const GameOverOverlay({
    super.key,
    required this.finalScore,
    required this.bestScore,
    required this.onPlayAgain,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNewRecord = finalScore >= bestScore && finalScore > 0;

    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? BloomTokens.darkSurface : BloomTokens.lightSurface,
            borderRadius: BorderRadius.circular(BloomTokens.radiusXLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF382320) : const Color(0xFFFDE8E5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco_outlined,
                  size: 36,
                  color: Color(0xFFE26D5C),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No Moves Left',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? BloomTokens.darkTextPrimary : BloomTokens.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'The garden is full, but your blooms will return!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? BloomTokens.darkTextSecondary : BloomTokens.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 20),
              // Score summary container
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141916) : const Color(0xFFF4F0E8),
                  borderRadius: BorderRadius.circular(BloomTokens.radiusMedium),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          'FINAL SCORE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                            color: isDark ? BloomTokens.darkTextSecondary : BloomTokens.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$finalScore',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark ? BloomTokens.darkTextPrimary : BloomTokens.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 36,
                      width: 1,
                      color: isDark ? const Color(0xFF2B3630) : const Color(0xFFDED8CE),
                    ),
                    Column(
                      children: [
                        Text(
                          isNewRecord ? 'NEW RECORD!' : 'BEST SCORE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                            color: isNewRecord
                                ? const Color(0xFF10B981)
                                : (isDark ? BloomTokens.darkTextSecondary : BloomTokens.lightTextSecondary),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$bestScore',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isNewRecord
                                ? const Color(0xFF10B981)
                                : (isDark ? BloomTokens.darkTextPrimary : BloomTokens.lightTextPrimary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Play Again',
                  icon: Icons.replay_rounded,
                  onPressed: onPlayAgain,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Home Menu',
                  icon: Icons.home_rounded,
                  isSecondary: true,
                  onPressed: onHome,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
