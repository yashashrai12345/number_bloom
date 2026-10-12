import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';

/// Renders a single number tile on the board with botanic styling,
/// responsive font sizing, and distinct bloom highlights.
class TileWidget extends StatelessWidget {
  final int value;
  final bool reducedMotion;

  const TileWidget({
    super.key,
    required this.value,
    this.reducedMotion = false,
  });

  double _getFontSize(int val) {
    final len = val.toString().length;
    if (len <= 2) return 30.0;
    if (len == 3) return 26.0;
    if (len == 4) return 22.0;
    if (len == 5) return 17.0;
    return 14.0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = BloomTokens.getTileStyle(value, isDark);

    if (value <= 0) {
      return Container(
        decoration: BoxDecoration(
          color: style.backgroundColor,
          borderRadius: BorderRadius.circular(BloomTokens.radiusMedium),
        ),
      );
    }

    final fontSize = _getFontSize(value);

    final tileBox = Container(
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(BloomTokens.radiusMedium),
        boxShadow: style.isGlow
            ? [
                BoxShadow(
                  color: style.backgroundColor.withValues(alpha: 0.4),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (style.isSpecialBloom) ...[
                  Icon(
                    Icons.spa_rounded,
                    size: fontSize * 0.7,
                    color: style.textColor.withValues(alpha: 0.85),
                  ),
                  const SizedBox(width: 3),
                ],
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w800,
                    color: style.textColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (reducedMotion) {
      return tileBox;
    }

    return TweenAnimationBuilder<double>(
      key: ValueKey('tile_${value}_$isDark'),
      tween: Tween<double>(begin: 0.85, end: 1.0),
      duration: BloomTokens.scalePopDuration,
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: tileBox,
    );
  }
}
