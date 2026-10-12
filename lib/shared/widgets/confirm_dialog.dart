import 'package:flutter/material.dart';
import '../../../core/design_tokens.dart';
import 'primary_button.dart';

/// Modal dialog confirming whether to discard an active game run.
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String cancelText;
  final String confirmText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const ConfirmDialog({
    super.key,
    this.title = 'Start New Game?',
    this.message = 'Your current board and score will be replaced. Keep playing or start a fresh garden?',
    this.cancelText = 'Keep Playing',
    this.confirmText = 'Start New Game',
    required this.onConfirm,
    this.onCancel,
  });

  static Future<bool?> show(
    BuildContext context, {
    String? title,
    String? message,
    String? cancelText,
    String? confirmText,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ConfirmDialog(
        title: title ?? 'Start New Game?',
        message: message ??
            'Your current board and score will be replaced. Keep playing or start fresh?',
        cancelText: cancelText ?? 'Keep Playing',
        confirmText: confirmText ?? 'Start New Game',
        onConfirm: () => Navigator.of(ctx).pop(true),
        onCancel: () => Navigator.of(ctx).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BloomTokens.radiusLarge),
      ),
      backgroundColor: isDark ? BloomTokens.darkSurface : BloomTokens.lightSurface,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDark ? BloomTokens.darkTextPrimary : BloomTokens.lightTextPrimary,
        ),
      ),
      content: Text(
        message,
        style: TextStyle(
          fontSize: 15,
          color: isDark ? BloomTokens.darkTextSecondary : BloomTokens.lightTextSecondary,
          height: 1.4,
        ),
      ),
      actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                if (onCancel != null) onCancel!();
                Navigator.of(context).maybePop(false);
              },
              child: Text(
                cancelText,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? BloomTokens.darkTextSecondary : BloomTokens.lightTextSecondary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            PrimaryButton(
              label: confirmText,
              minHeight: 44,
              backgroundColor: const Color(0xFFE26D5C),
              onPressed: () {
                onConfirm();
                Navigator.of(context).maybePop(true);
              },
            ),
          ],
        ),
      ],
    );
  }
}
