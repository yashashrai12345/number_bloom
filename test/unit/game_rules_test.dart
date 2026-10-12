import 'package:flutter_test/flutter_test.dart';
import 'package:number_bloom/features/game/domain/board.dart';
import 'package:number_bloom/features/game/domain/game_rules.dart';
import 'package:number_bloom/features/game/domain/move_direction.dart';

void main() {
  group('GameRules - Single line sliding and merging (PRD Section 4.3)', () {
    test('[2, 2, 0, 0] -> [4, 0, 0, 0] with score +4', () {
      final res = GameRules.slideLine([2, 2, 0, 0]);
      expect(res.newLine, equals([4, 0, 0, 0]));
      expect(res.scoreGained, equals(4));
      expect(res.mergesCount, equals(1));
    });

    test('[2, 2, 2, 2] -> [4, 4, 0, 0] with score +8', () {
      final res = GameRules.slideLine([2, 2, 2, 2]);
      expect(res.newLine, equals([4, 4, 0, 0]));
      expect(res.scoreGained, equals(8));
      expect(res.mergesCount, equals(2));
    });

    test('[2, 2, 4, 0] -> [4, 4, 0, 0] with score +4 (no double merge)', () {
      final res = GameRules.slideLine([2, 2, 4, 0]);
      expect(res.newLine, equals([4, 4, 0, 0]));
      expect(res.scoreGained, equals(4));
      expect(res.mergesCount, equals(1));
    });

    test('[4, 4, 8, 0] -> [8, 8, 0, 0] with score +8', () {
      final res = GameRules.slideLine([4, 4, 8, 0]);
      expect(res.newLine, equals([8, 8, 0, 0]));
      expect(res.scoreGained, equals(8));
      expect(res.mergesCount, equals(1));
    });

    test('[2, 0, 2, 4] -> [4, 4, 0, 0] with score +4', () {
      final res = GameRules.slideLine([2, 0, 2, 4]);
      expect(res.newLine, equals([4, 4, 0, 0]));
      expect(res.scoreGained, equals(4));
      expect(res.mergesCount, equals(1));
    });

    test('[2, 4, 8, 16] -> unchanged, score +0', () {
      final res = GameRules.slideLine([2, 4, 8, 16]);
      expect(res.newLine, equals([2, 4, 8, 16]));
      expect(res.scoreGained, equals(0));
      expect(res.mergesCount, equals(0));
    });

    test('Slide only without merge: [0, 0, 2, 4] -> [2, 4, 0, 0], score +0', () {
      final res = GameRules.slideLine([0, 0, 2, 4]);
      expect(res.newLine, equals([2, 4, 0, 0]));
      expect(res.scoreGained, equals(0));
      expect(res.mergesCount, equals(0));
    });
  });

  group('GameRules - 4-Direction movement', () {
    test('Move Left full board row check', () {
      final board = Board.fromMatrix([
        [2, 2, 0, 0],
        [4, 4, 8, 0],
        [0, 2, 0, 2],
        [0, 0, 0, 0],
      ]);
      final result = GameRules.applyMove(board, MoveDirection.left);
      expect(result.changed, isTrue);
      expect(result.scoreGained, equals(4 + 8 + 4));
      expect(result.mergesCount, equals(3));
      expect(result.board.toMatrix(), equals([
        [4, 0, 0, 0],
        [8, 8, 0, 0],
        [4, 0, 0, 0],
        [0, 0, 0, 0],
      ]));
    });

    test('Move Right full board row check', () {
      final board = Board.fromMatrix([
        [2, 2, 0, 0],
        [4, 0, 4, 8],
        [0, 2, 0, 2],
        [0, 0, 0, 0],
      ]);
      final result = GameRules.applyMove(board, MoveDirection.right);
      expect(result.changed, isTrue);
      expect(result.board.toMatrix(), equals([
        [0, 0, 0, 4],
        [0, 0, 8, 8],
        [0, 0, 0, 4],
        [0, 0, 0, 0],
      ]));
    });

    test('Move Up column check', () {
      final board = Board.fromMatrix([
        [2, 4, 0, 0],
        [2, 4, 0, 0],
        [4, 8, 0, 0],
        [0, 0, 0, 0],
      ]);
      final result = GameRules.applyMove(board, MoveDirection.up);
      expect(result.changed, isTrue);
      expect(result.board.toMatrix(), equals([
        [4, 8, 0, 0],
        [4, 8, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]));
      expect(result.scoreGained, equals(4 + 8));
    });

    test('Move Down column check', () {
      final board = Board.fromMatrix([
        [2, 4, 0, 0],
        [2, 4, 0, 0],
        [4, 8, 0, 0],
        [0, 0, 0, 0],
      ]);
      final result = GameRules.applyMove(board, MoveDirection.down);
      expect(result.changed, isTrue);
      expect(result.board.toMatrix(), equals([
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [4, 8, 0, 0],
        [4, 8, 0, 0],
      ]));
      expect(result.scoreGained, equals(4 + 8));
    });

    test('Invalid move returns changed = false and scoreGained = 0', () {
      final board = Board.fromMatrix([
        [2, 4, 8, 16],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      final resultLeft = GameRules.applyMove(board, MoveDirection.left);
      expect(resultLeft.changed, isFalse);
      expect(resultLeft.scoreGained, equals(0));
      expect(resultLeft.mergesCount, equals(0));
      expect(resultLeft.board, equals(board));

      final resultUp = GameRules.applyMove(board, MoveDirection.up);
      expect(resultUp.changed, isFalse);
      expect(resultUp.scoreGained, equals(0));
      expect(resultUp.board, equals(board));
    });
  });
}
