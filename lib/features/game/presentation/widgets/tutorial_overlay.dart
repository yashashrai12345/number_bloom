import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';
import '../../../../shared/widgets/primary_button.dart';

/// Lightweight skippable first-launch tutorial overlay.
class TutorialOverlay extends StatelessWidget {
  final VoidCallback onDismiss;

  const TutorialOverlay({
    super.key,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Container(
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
                    Icons.touch_app_rounded,
                    size: 30,
                    color: isDark ? BloomTokens.darkAccent : BloomTokens.lightAccent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'How to Play',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? BloomTokens.darkTextPrimary : BloomTokens.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildStep(
                icon: Icons.swipe_rounded,
                title: 'Swipe in 4 Directions',
                desc: 'Slide all tiles up, down, left, or right across the 4x4 garden.',
                isDark: isDark,
              ),
              const SizedBox(height: 14),
              _buildStep(
                icon: Icons.merge_type_rounded,
                title: 'Merge Equal Numbers',
                desc: 'When two tiles with the same number collide, they blossom into their sum!',
                isDark: isDark,
              ),
              const SizedBox(height: 14),
              _buildStep(
                icon: Icons.spa_rounded,
                title: 'Reach 2048',
                desc: 'Keep cultivating until you create the 2048 bloom, then continue for the high score!',
                isDark: isDark,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Got it, Let\'s Play!',
                  onPressed: onDismiss,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep({
    required IconData icon,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF26322B) : const Color(0xFFE9F3EC),
            borderRadius: BorderRadius.circular(BloomTokens.radiusSmall),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? BloomTokens.darkAccent : BloomTokens.lightAccent,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? BloomTokens.darkTextPrimary : BloomTokens.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? BloomTokens.darkTextSecondary : BloomTokens.lightTextSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
