import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/primary_button.dart';

/// Celebratory overlay when reaching the 2048 bloom milestone.
class WinOverlay extends StatelessWidget {
  final int currentScore;
  final VoidCallback onContinue;
  final VoidCallback onNewGame;
  final bool reducedMotion;

  const WinOverlay({
    super.key,
    required this.currentScore,
    required this.onContinue,
    required this.onNewGame,
    this.reducedMotion = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? BloomTokens.darkSurface : BloomTokens.lightSurface,
        borderRadius: BorderRadius.circular(BloomTokens.radiusXLarge),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.spa_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Number Bloom!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: isDark ? BloomTokens.darkTextPrimary : BloomTokens.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You cultivated the 2048 tile!\nScore: $currentScore',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? BloomTokens.darkTextSecondary : BloomTokens.lightTextSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: 'Continue Playing',
              icon: Icons.arrow_forward_rounded,
              backgroundColor: const Color(0xFF10B981),
              onPressed: onContinue,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: 'Start New Garden',
              icon: Icons.refresh_rounded,
              isSecondary: true,
              onPressed: () async {
                final confirm = await ConfirmDialog.show(
                  context,
                  title: 'Start Fresh Garden?',
                  message: 'Starting a new game will begin from 0. Your best score remains preserved.',
                );
                if (confirm == true) {
                  onNewGame();
                }
              },
            ),
          ),
        ],
      ),
    );

    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: reducedMotion
            ? content
            : TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: content,
              ),
      ),
    );
  }
}
