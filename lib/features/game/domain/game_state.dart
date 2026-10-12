import 'board.dart';

/// The active gameplay state.
class GameState {
  final Board board;
  final int score;
  final int bestScore;
  final int moveCount;
  final bool hasWon;
  final bool winOverlayDismissed;
  final bool isGameOver;
  final bool isPaused;
  final bool isAnimating;

  const GameState({
    required this.board,
    required this.score,
    required this.bestScore,
    required this.moveCount,
    required this.hasWon,
    required this.winOverlayDismissed,
    required this.isGameOver,
    this.isPaused = false,
    this.isAnimating = false,
  });

  /// Factory for a clean initial game state.
  factory GameState.initial({
    required Board board,
    int bestScore = 0,
  }) {
    return GameState(
      board: board,
      score: 0,
      bestScore: bestScore,
      moveCount: 0,
      hasWon: false,
      winOverlayDismissed: false,
      isGameOver: false,
      isPaused: false,
      isAnimating: false,
    );
  }

  GameState copyWith({
    Board? board,
    int? score,
    int? bestScore,
    int? moveCount,
    bool? hasWon,
    bool? winOverlayDismissed,
    bool? isGameOver,
    bool? isPaused,
    bool? isAnimating,
  }) {
    return GameState(
      board: board ?? this.board,
      score: score ?? this.score,
      bestScore: bestScore ?? this.bestScore,
      moveCount: moveCount ?? this.moveCount,
      hasWon: hasWon ?? this.hasWon,
      winOverlayDismissed: winOverlayDismissed ?? this.winOverlayDismissed,
      isGameOver: isGameOver ?? this.isGameOver,
      isPaused: isPaused ?? this.isPaused,
      isAnimating: isAnimating ?? this.isAnimating,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'board': board.toMatrix(),
      'score': score,
      'moveCount': moveCount,
      'hasWon': hasWon,
      'winOverlayDismissed': winOverlayDismissed,
      'isGameOver': isGameOver,
    };
  }

  static GameState? fromJson(Map<String, dynamic> json, int currentBestScore) {
    try {
      final rawBoard = json['board'] as List<dynamic>?;
      if (rawBoard == null || rawBoard.length != 4) return null;
      final matrix = <List<int>>[];
      for (final row in rawBoard) {
        if (row is! List || row.length != 4) return null;
        matrix.add(row.map((e) => (e as num).toInt()).toList());
      }

      return GameState(
        board: Board.fromMatrix(matrix),
        score: (json['score'] as num?)?.toInt() ?? 0,
        bestScore: currentBestScore,
        moveCount: (json['moveCount'] as num?)?.toInt() ?? 0,
        hasWon: (json['hasWon'] as bool?) ?? false,
        winOverlayDismissed: (json['winOverlayDismissed'] as bool?) ?? false,
        isGameOver: (json['isGameOver'] as bool?) ?? false,
        isPaused: false,
        isAnimating: false,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Statistics accumulated over games.
class GameStats {
  final int gamesPlayed;
  final int totalMerges;
  final int highestTile;

  const GameStats({
    this.gamesPlayed = 0,
    this.totalMerges = 0,
    this.highestTile = 0,
  });

  GameStats copyWith({
    int? gamesPlayed,
    int? totalMerges,
    int? highestTile,
  }) {
    return GameStats(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      totalMerges: totalMerges ?? this.totalMerges,
      highestTile: highestTile ?? this.highestTile,
    );
  }

  Map<String, dynamic> toJson() => {
        'gamesPlayed': gamesPlayed,
        'totalMerges': totalMerges,
        'highestTile': highestTile,
      };

  factory GameStats.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const GameStats();
    return GameStats(
      gamesPlayed: (json['gamesPlayed'] as num?)?.toInt() ?? 0,
      totalMerges: (json['totalMerges'] as num?)?.toInt() ?? 0,
      highestTile: (json['highestTile'] as num?)?.toInt() ?? 0,
    );
  }
}
