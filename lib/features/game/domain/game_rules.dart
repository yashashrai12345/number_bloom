import 'board.dart';
import 'move_direction.dart';
import 'move_result.dart';
import 'random_provider.dart';

/// Pure domain game rules engine for Number Bloom.
///
/// Contains deterministic movement, merge logic, scoring, tile spawning,
/// win checking, and game-over detection without any UI dependencies.
class GameRules {
  static const int winThreshold = 2048;
  static const double spawnTwoProbability = 0.90;

  /// Creates a starting board with two randomly spawned tiles (2 or 4).
  static Board createInitialBoard(RandomProvider rng) {
    var board = Board.empty();
    board = spawnTile(board, rng);
    board = spawnTile(board, rng);
    return board;
  }

  /// Spawns a single tile (2 with 90% chance, 4 with 10% chance) into an empty cell.
  /// If the board has no empty cells, returns the board unchanged.
  static Board spawnTile(Board board, RandomProvider rng) {
    final empty = board.emptyCells;
    if (empty.isEmpty) return board;

    final cellIndex = rng.nextInt(empty.length);
    final (row, col) = empty[cellIndex];
    final value = rng.nextDouble() < spawnTwoProbability ? 2 : 4;
    return board.set(row, col, value);
  }

  /// Slides and merges a single 4-element line towards index 0 (destination edge).
  ///
  /// Returns a record of:
  /// - [newLine]: The 4-element line after sliding, merging, and zero-padding.
  /// - [scoreGained]: Total score from merged tiles in this line.
  /// - [mergesCount]: Number of merges occurred in this line.
  /// - [mergedIndices]: The indices in [newLine] where merges occurred.
  /// - [mergedValues]: The resulting values at those merged indices.
  static ({
    List<int> newLine,
    int scoreGained,
    int mergesCount,
    List<int> mergedIndices,
    List<int> mergedValues,
  }) slideLine(List<int> line) {
    assert(line.length == Board.size);

    final nonZero = line.where((v) => v != 0).toList();
    final result = <int>[];
    int scoreGained = 0;
    int mergesCount = 0;
    final mergedIndices = <int>[];
    final mergedValues = <int>[];

    int i = 0;
    while (i < nonZero.length) {
      if (i + 1 < nonZero.length && nonZero[i] == nonZero[i + 1]) {
        final mergedVal = nonZero[i] * 2;
        mergedIndices.add(result.length);
        mergedValues.add(mergedVal);
        result.add(mergedVal);
        scoreGained += mergedVal;
        mergesCount++;
        i += 2; // Each tile can merge at most once per move
      } else {
        result.add(nonZero[i]);
        i += 1;
      }
    }

    while (result.length < Board.size) {
      result.add(0);
    }

    return (
      newLine: result,
      scoreGained: scoreGained,
      mergesCount: mergesCount,
      mergedIndices: mergedIndices,
      mergedValues: mergedValues,
    );
  }

  /// Applies directional movement to the board.
  ///
  /// Computes deterministic slide and merge results before any new tile is spawned.
  /// If the board state did not change, [MoveResult.changed] will be false.
  static MoveResult applyMove(Board board, MoveDirection direction) {
    int totalScore = 0;
    int totalMerges = 0;
    final mergeEvents = <MergeEvent>[];
    final newGrid = List.generate(
      Board.size,
      (_) => List.filled(Board.size, 0),
    );

    switch (direction) {
      case MoveDirection.left:
        for (int r = 0; r < Board.size; r++) {
          final line = [
            board.get(r, 0),
            board.get(r, 1),
            board.get(r, 2),
            board.get(r, 3),
          ];
          final outcome = slideLine(line);
          totalScore += outcome.scoreGained;
          totalMerges += outcome.mergesCount;
          for (int c = 0; c < Board.size; c++) {
            newGrid[r][c] = outcome.newLine[c];
          }
          for (int k = 0; k < outcome.mergedIndices.length; k++) {
            mergeEvents.add(
              MergeEvent(
                row: r,
                col: outcome.mergedIndices[k],
                resultingValue: outcome.mergedValues[k],
              ),
            );
          }
        }
        break;

      case MoveDirection.right:
        for (int r = 0; r < Board.size; r++) {
          final line = [
            board.get(r, 3),
            board.get(r, 2),
            board.get(r, 1),
            board.get(r, 0),
          ];
          final outcome = slideLine(line);
          totalScore += outcome.scoreGained;
          totalMerges += outcome.mergesCount;
          for (int c = 0; c < Board.size; c++) {
            newGrid[r][3 - c] = outcome.newLine[c];
          }
          for (int k = 0; k < outcome.mergedIndices.length; k++) {
            mergeEvents.add(
              MergeEvent(
                row: r,
                col: 3 - outcome.mergedIndices[k],
                resultingValue: outcome.mergedValues[k],
              ),
            );
          }
        }
        break;

      case MoveDirection.up:
        for (int c = 0; c < Board.size; c++) {
          final line = [
            board.get(0, c),
            board.get(1, c),
            board.get(2, c),
            board.get(3, c),
          ];
          final outcome = slideLine(line);
          totalScore += outcome.scoreGained;
          totalMerges += outcome.mergesCount;
          for (int r = 0; r < Board.size; r++) {
            newGrid[r][c] = outcome.newLine[r];
          }
          for (int k = 0; k < outcome.mergedIndices.length; k++) {
            mergeEvents.add(
              MergeEvent(
                row: outcome.mergedIndices[k],
                col: c,
                resultingValue: outcome.mergedValues[k],
              ),
            );
          }
        }
        break;

      case MoveDirection.down:
        for (int c = 0; c < Board.size; c++) {
          final line = [
            board.get(3, c),
            board.get(2, c),
            board.get(1, c),
            board.get(0, c),
          ];
          final outcome = slideLine(line);
          totalScore += outcome.scoreGained;
          totalMerges += outcome.mergesCount;
          for (int r = 0; r < Board.size; r++) {
            newGrid[3 - r][c] = outcome.newLine[r];
          }
          for (int k = 0; k < outcome.mergedIndices.length; k++) {
            mergeEvents.add(
              MergeEvent(
                row: 3 - outcome.mergedIndices[k],
                col: c,
                resultingValue: outcome.mergedValues[k],
              ),
            );
          }
        }
        break;
    }

    final resultingBoard = Board.fromMatrix(newGrid);
    final changed = resultingBoard != board;

    return MoveResult(
      board: resultingBoard,
      changed: changed,
      scoreGained: changed ? totalScore : 0,
      mergesCount: changed ? totalMerges : 0,
      merges: changed ? mergeEvents : const [],
    );
  }

  /// Checks if any valid move exists on the board.
  ///
  /// A move is valid if the board is not full, or if there is any horizontally
  /// or vertically adjacent pair of equal non-zero tiles.
  static bool hasAvailableMoves(Board board) {
    if (!board.isFull) return true;

    // Check horizontal neighbors
    for (int r = 0; r < Board.size; r++) {
      for (int c = 0; c < Board.size - 1; c++) {
        if (board.get(r, c) == board.get(r, c + 1)) {
          return true;
        }
      }
    }

    // Check vertical neighbors
    for (int r = 0; r < Board.size - 1; r++) {
      for (int c = 0; c < Board.size; c++) {
        if (board.get(r, c) == board.get(r + 1, c)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Determines if the game is over (no empty cells and no adjacent equal tiles).
  static bool isGameOver(Board board) => !hasAvailableMoves(board);

  /// Checks if the board contains any tile with value >= [targetValue].
  static bool hasTileAtLeast(Board board, [int targetValue = winThreshold]) {
    for (int r = 0; r < Board.size; r++) {
      for (int c = 0; c < Board.size; c++) {
        if (board.get(r, c) >= targetValue) {
          return true;
        }
      }
    }
    return false;
  }
}
