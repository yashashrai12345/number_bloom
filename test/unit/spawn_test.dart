import 'package:flutter_test/flutter_test.dart';
import 'package:number_bloom/features/game/domain/board.dart';
import 'package:number_bloom/features/game/domain/game_rules.dart';
import 'package:number_bloom/features/game/domain/random_provider.dart';

void main() {
  group('Tile Spawning (AC-GAME-01, AC-GAME-05, AC-GAME-06)', () {
    test('AC-GAME-01: Initial board has exactly two non-empty tiles', () {
      final rng = DefaultRandomProvider();
      for (int i = 0; i < 20; i++) {
        final board = GameRules.createInitialBoard(rng);
        expect(board.occupiedCount, equals(2));
        expect(board.emptyCells.length, equals(14));
        final tiles = board.toMatrix().expand((r) => r).where((v) => v > 0).toList();
        expect(tiles.length, equals(2));
        expect(tiles.every((v) => v == 2 || v == 4), isTrue);
      }
    });

    test('AC-GAME-05: Spawning on empty board adds exactly 1 tile', () {
      final board = Board.empty();
      final rng = DeterministicRandomProvider(
        intValues: [0], // Selects cell 0 (0, 0)
        doubleValues: [0.5], // < 0.9 -> value 2
      );
      final newBoard = GameRules.spawnTile(board, rng);
      expect(newBoard.occupiedCount, equals(1));
      expect(newBoard.get(0, 0), equals(2));
    });

    test('AC-GAME-06: Spawn value distribution (90% 2, 10% 4)', () {
      final board = Board.empty();
      // Double value < 0.9 -> 2
      final rng2 = DeterministicRandomProvider(
        intValues: [0],
        doubleValues: [0.89],
      );
      final board2 = GameRules.spawnTile(board, rng2);
      expect(board2.get(0, 0), equals(2));

      // Double value >= 0.9 -> 4
      final rng4 = DeterministicRandomProvider(
        intValues: [0],
        doubleValues: [0.90],
      );
      final board4 = GameRules.spawnTile(board, rng4);
      expect(board4.get(0, 0), equals(4));
    });

    test('Spawn never overwrites an occupied cell', () {
      var board = Board.fromMatrix([
        [2, 4, 8, 16],
        [32, 64, 128, 256],
        [512, 1024, 2048, 4096],
        [8192, 16384, 32768, 0], // Only (3, 3) is empty
      ]);
      final rng = DeterministicRandomProvider(
        intValues: [0],
        doubleValues: [0.1],
      );
      final newBoard = GameRules.spawnTile(board, rng);
      expect(newBoard.get(3, 3), equals(2));
      // All other cells are unchanged
      expect(newBoard.get(0, 0), equals(2));
      expect(newBoard.get(0, 1), equals(4));
    });

    test('Spawning when board is full returns unchanged board without error', () {
      final fullBoard = Board.fromMatrix([
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 2],
      ]);
      final rng = DefaultRandomProvider();
      final res = GameRules.spawnTile(fullBoard, rng);
      expect(res, equals(fullBoard));
    });
  });
}
