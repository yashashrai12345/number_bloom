import 'package:flutter/material.dart';
import '../../../core/design_tokens.dart';

/// Standard tactile button used for primary actions with accessible touch targets.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isSecondary;
  final double minHeight;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.isSecondary = false,
    this.minHeight = 52.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultBg = isSecondary
        ? (isDark ? BloomTokens.darkSurface : const Color(0xFFEFEBE4))
        : (isDark ? BloomTokens.darkAccent : BloomTokens.lightAccent);

    final defaultText = isSecondary
        ? (isDark ? BloomTokens.darkTextPrimary : BloomTokens.lightTextPrimary)
        : Colors.white;

    final bg = backgroundColor ?? defaultBg;
    final fg = textColor ?? defaultText;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight, minWidth: 120),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: isSecondary ? 0 : 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BloomTokens.radiusMedium),
            side: isSecondary
                ? BorderSide(
                    color: isDark ? const Color(0xFF2E3832) : const Color(0xFFDED8CD),
                    width: 1,
                  )
                : BorderSide.none,
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: fg),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: fg,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
