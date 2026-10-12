import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';

/// Distinct score badge card displaying current score or best score.
class ScoreCard extends StatelessWidget {
  final String title;
  final int score;
  final IconData icon;
  final bool isHighlight;

  const ScoreCard({
    super.key,
    required this.title,
    required this.score,
    required this.icon,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isHighlight
        ? (isDark ? const Color(0xFF22352B) : const Color(0xFFE8F4EC))
        : (isDark ? BloomTokens.darkSurface : BloomTokens.lightSurface);

    final borderColor = isHighlight
        ? (isDark
            ? BloomTokens.darkAccent.withValues(alpha: 0.5)
            : BloomTokens.lightAccent.withValues(alpha: 0.3))
        : (isDark ? const Color(0xFF2B3630) : const Color(0xFFE5DFD4));

    final iconColor = isHighlight
        ? (isDark ? BloomTokens.darkAccent : BloomTokens.lightAccent)
        : (isDark ? BloomTokens.darkTextSecondary : BloomTokens.lightTextSecondary);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(BloomTokens.radiusMedium),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 4),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: isDark ? BloomTokens.darkTextSecondary : BloomTokens.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            score.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? BloomTokens.darkTextPrimary : BloomTokens.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
