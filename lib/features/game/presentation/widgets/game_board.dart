import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';
import '../../domain/board.dart';
import '../../domain/move_direction.dart';
import 'tile_widget.dart';

/// Interactive 4x4 puzzle board that handles thresholded directional gestures.
class GameBoard extends StatefulWidget {
  final Board board;
  final void Function(MoveDirection direction) onMove;
  final bool isInputLocked;
  final bool reducedMotion;

  const GameBoard({
    super.key,
    required this.board,
    required this.onMove,
    this.isInputLocked = false,
    this.reducedMotion = false,
  });

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  Offset? _dragStart;
  bool _gestureTriggered = false;

  static const double _swipeThreshold = 24.0;

  void _handlePanStart(DragStartDetails details) {
    if (widget.isInputLocked) return;
    _dragStart = details.localPosition;
    _gestureTriggered = false;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (widget.isInputLocked || _gestureTriggered || _dragStart == null) return;

    final dx = details.localPosition.dx - _dragStart!.dx;
    final dy = details.localPosition.dy - _dragStart!.dy;

    // Check if movement exceeds threshold
    if (dx.abs() >= _swipeThreshold || dy.abs() >= _swipeThreshold) {
      _gestureTriggered = true;

      // Select dominant axis to prevent accidental diagonal moves
      if (dx.abs() > dy.abs()) {
        widget.onMove(dx > 0 ? MoveDirection.right : MoveDirection.left);
      } else {
        widget.onMove(dy > 0 ? MoveDirection.down : MoveDirection.up);
      }
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    _dragStart = null;
    _gestureTriggered = false;
  }

  void _handlePanCancel() {
    _dragStart = null;
    _gestureTriggered = false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final boardBg = isDark ? BloomTokens.darkBoardBg : BloomTokens.lightBoardBg;

    return AspectRatio(
      aspectRatio: 1.0,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: _handlePanStart,
        onPanUpdate: _handlePanUpdate,
        onPanEnd: _handlePanEnd,
        onPanCancel: _handlePanCancel,
        child: Container(
          padding: const EdgeInsets.all(BloomTokens.space12),
          decoration: BoxDecoration(
            color: boardBg,
            borderRadius: BorderRadius.circular(BloomTokens.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: List.generate(Board.size, (r) {
              return Expanded(
                child: Row(
                  children: List.generate(Board.size, (c) {
                    final value = widget.board.get(r, c);
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: TileWidget(
                          value: value,
                          reducedMotion: widget.reducedMotion,
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
