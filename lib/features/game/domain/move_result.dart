import 'board.dart';

/// Details about a single merge that occurred during a move.
class MergeEvent {
  final int row;
  final int col;
  final int resultingValue;

  const MergeEvent({
    required this.row,
    required this.col,
    required this.resultingValue,
  });

  @override
  String toString() => 'MergeEvent(($row, $col) -> $resultingValue)';
}

/// The result of attempting a move in a specific direction.
class MoveResult {
  /// The resulting board after sliding and merging (before any new tile spawn).
  final Board board;

  /// True if the board state changed compared to the starting board.
  final bool changed;

  /// Total score gained from all merges in this move.
  final int scoreGained;

  /// Number of successful tile merges that occurred.
  final int mergesCount;

  /// Detailed list of merge events (positions and values).
  final List<MergeEvent> merges;

  const MoveResult({
    required this.board,
    required this.changed,
    required this.scoreGained,
    required this.mergesCount,
    this.merges = const [],
  });

  @override
  String toString() =>
      'MoveResult(changed: $changed, scoreGained: $scoreGained, merges: $mergesCount)';
}
