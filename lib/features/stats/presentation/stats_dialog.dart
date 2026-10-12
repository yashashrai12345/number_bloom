import 'package:flutter/material.dart';
import '../../../core/design_tokens.dart';
import '../../game/domain/game_state.dart';

/// Modal dialog displaying player's historical gameplay statistics.
class StatsDialog extends StatelessWidget {
  final GameStats stats;
  final int bestScore;

  const StatsDialog({
    super.key,
    required this.stats,
    required this.bestScore,
  });

  static void show(BuildContext context, {required GameStats stats, required int bestScore}) {
    showDialog(
      context: context,
      builder: (_) => StatsDialog(stats: stats, bestScore: bestScore),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BloomTokens.radiusXLarge),
      ),
      backgroundColor: isDark ? BloomTokens.darkSurface : BloomTokens.lightSurface,
      title: Row(
        children: [
          Icon(
            Icons.bar_chart_rounded,
            color: isDark ? BloomTokens.darkAccent : BloomTokens.lightAccent,
          ),
          const SizedBox(width: 8),
          Text(
            'Garden Statistics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? BloomTokens.darkTextPrimary : BloomTokens.lightTextPrimary,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatRow('Best Score', bestScore.toString(), Icons.emoji_events_rounded, isDark),
          const Divider(height: 20),
          _buildStatRow('Games Played', stats.gamesPlayed.toString(), Icons.sports_esports_rounded, isDark),
          const Divider(height: 20),
          _buildStatRow('Total Merges', stats.totalMerges.toString(), Icons.merge_type_rounded, isDark),
          const Divider(height: 20),
          _buildStatRow(
            'Highest Tile',
            stats.highestTile > 0 ? stats.highestTile.toString() : '—',
            Icons.spa_rounded,
            isDark,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Close',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? BloomTokens.darkAccent : BloomTokens.lightAccent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? BloomTokens.darkTextSecondary : BloomTokens.lightTextSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? BloomTokens.darkTextSecondary : BloomTokens.lightTextSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? BloomTokens.darkTextPrimary : BloomTokens.lightTextPrimary,
          ),
        ),
      ],
    );
  }
}
