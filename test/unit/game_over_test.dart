import 'package:flutter_test/flutter_test.dart';
import 'package:number_bloom/features/game/domain/board.dart';
import 'package:number_bloom/features/game/domain/game_rules.dart';

void main() {
  group('GameOver & Win Conditions (AC-GAME-09, AC-GAME-10)', () {
    test('AC-GAME-09: Full board with equal adjacent neighbors is NOT game over', () {
      // Horizontal pair: (0, 0) and (0, 1) are both 2
      final boardWithHorizontalPair = Board.fromMatrix([
        [2, 2, 4, 8],
        [16, 32, 64, 128],
        [256, 512, 1024, 2048],
        [4096, 8192, 16384, 32768],
      ]);
      expect(GameRules.isGameOver(boardWithHorizontalPair), isFalse);
      expect(GameRules.hasAvailableMoves(boardWithHorizontalPair), isTrue);

      // Vertical pair: (2, 3) and (3, 3) are both 4
      final boardWithVerticalPair = Board.fromMatrix([
        [2, 4, 8, 16],
        [32, 64, 128, 256],
        [512, 1024, 2048, 4],
        [8192, 16384, 32768, 4],
      ]);
      expect(GameRules.isGameOver(boardWithVerticalPair), isFalse);
      expect(GameRules.hasAvailableMoves(boardWithVerticalPair), isTrue);
    });

    test('AC-GAME-10: Full board with no equal orthogonal neighbors IS game over', () {
      final gameOverBoard = Board.fromMatrix([
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 2],
      ]);
      expect(GameRules.isGameOver(gameOverBoard), isTrue);
      expect(GameRules.hasAvailableMoves(gameOverBoard), isFalse);
    });

    test('Non-full board is never game over', () {
      final board = Board.fromMatrix([
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 0], // one empty cell
      ]);
      expect(GameRules.isGameOver(board), isFalse);
    });

    test('Win condition: hasTileAtLeast detects 2048 and beyond', () {
      final boardWithout2048 = Board.fromMatrix([
        [2, 4, 8, 16],
        [32, 64, 128, 256],
        [512, 1024, 0, 0],
        [0, 0, 0, 0],
      ]);
      expect(GameRules.hasTileAtLeast(boardWithout2048, 2048), isFalse);

      final boardWith2048 = boardWithout2048.set(2, 2, 2048);
      expect(GameRules.hasTileAtLeast(boardWith2048, 2048), isTrue);

      final boardWith4096 = boardWith2048.set(2, 3, 4096);
      expect(GameRules.hasTileAtLeast(boardWith4096, 2048), isTrue);
    });
  });
}
