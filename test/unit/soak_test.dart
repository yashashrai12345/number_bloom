import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:number_bloom/features/game/domain/game_rules.dart';
import 'package:number_bloom/features/game/domain/move_direction.dart';
import 'package:number_bloom/features/game/domain/random_provider.dart';

bool isPowerOfTwo(int n) {
  return n > 0 && (n & (n - 1)) == 0;
}

void main() {
  group('Randomized gameplay soak test (PRD Section 12.4)', () {
    test('1000 seeded random moves maintain all domain invariants', () {
      const fixedSeed = 424242;
      final seedRandom = math.Random(fixedSeed);
      final rng = DefaultRandomProvider(seedRandom);

      var board = GameRules.createInitialBoard(rng);
      int score = 0;

      for (int moveIndex = 0; moveIndex < 1000; moveIndex++) {
        // Invariant 1: Board is 4x4
        expect(board.toMatrix().length, equals(4));
        expect(board.toMatrix().every((row) => row.length == 4), isTrue);

        // Invariant 2: Every non-empty tile is a power of two
        for (int r = 0; r < 4; r++) {
          for (int c = 0; c < 4; c++) {
            final val = board.get(r, c);
            if (val > 0) {
              expect(isPowerOfTwo(val), isTrue,
                  reason: 'Tile at ($r, $c) with value $val must be power of 2');
            }
          }
        }

        // Invariant 3: Occupied count <= 16
        expect(board.occupiedCount, inInclusiveRange(0, 16));

        // If game is over, restart board
        if (GameRules.isGameOver(board)) {
          board = GameRules.createInitialBoard(rng);
          score = 0;
          continue;
        }

        // Pick a random direction
        final direction = MoveDirection.values[rng.nextInt(4)];
        final result = GameRules.applyMove(board, direction);

        if (!result.changed) {
          // Invariant 5: Invalid move produces no score gain and does not spawn a tile
          expect(result.scoreGained, equals(0));
          expect(result.board, equals(board));
        } else {
          // Invariant 4: Score never decreases
          final prevScore = score;
          score += result.scoreGained;
          expect(score, greaterThanOrEqualTo(prevScore));

          // Valid move: spawn exactly 1 tile if empty cells exist
          final prevEmptyCount = result.board.emptyCells.length;
          board = GameRules.spawnTile(result.board, rng);
          if (prevEmptyCount > 0) {
            expect(board.emptyCells.length, equals(prevEmptyCount - 1));
          }
        }
      }
    });
  });
}
