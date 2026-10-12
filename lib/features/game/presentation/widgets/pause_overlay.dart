import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/primary_button.dart';

/// Pause menu modal overlay.
class PauseOverlay extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  const PauseOverlay({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Colors.black.withValues(alpha: 0.65),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? BloomTokens.darkSurface : BloomTokens.lightSurface,
            borderRadius: BorderRadius.circular(BloomTokens.radiusXLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pause_circle_outline_rounded,
                    size: 28,
                    color: isDark ? BloomTokens.darkAccent : BloomTokens.lightAccent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Paused',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? BloomTokens.darkTextPrimary : BloomTokens.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Resume',
                  icon: Icons.play_arrow_rounded,
                  onPressed: onResume,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Restart Run',
                  icon: Icons.refresh_rounded,
                  isSecondary: true,
                  onPressed: () async {
                    final shouldRestart = await ConfirmDialog.show(context);
                    if (shouldRestart == true) {
                      onRestart();
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Main Menu',
                  icon: Icons.home_rounded,
                  isSecondary: true,
                  onPressed: () async {
                    final shouldLeave = await ConfirmDialog.show(
                      context,
                      title: 'Return to Menu?',
                      message: 'Your current game will remain saved so you can continue anytime.',
                      confirmText: 'Return Home',
                      cancelText: 'Stay in Game',
                    );
                    if (shouldLeave == true) {
                      onHome();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
