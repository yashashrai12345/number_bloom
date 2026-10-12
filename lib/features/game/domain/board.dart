/// Represents an immutable 4x4 number board.
class Board {
  static const int size = 4;

  final List<List<int>> _grid;

  /// Creates a board with the given 4x4 grid.
  const Board(this._grid);

  /// Creates an empty 4x4 board initialized with zeros.
  factory Board.empty() {
    return Board(List.generate(size, (_) => List.filled(size, 0, growable: false), growable: false));
  }

  /// Creates a board from a raw 2D list of integers.
  factory Board.fromMatrix(List<List<int>> matrix) {
    if (matrix.length != size || matrix.any((row) => row.length != size)) {
      throw ArgumentError('Matrix must be exactly 4x4');
    }
    final copy = List.generate(
      size,
      (r) => List.generate(size, (c) => matrix[r][c], growable: false),
      growable: false,
    );
    return Board(copy);
  }

  /// Returns the value at [row], [col]. 0 represents an empty cell.
  int get(int row, int col) => _grid[row][col];

  /// Returns a new board with the cell at [row], [col] updated to [value].
  Board set(int row, int col, int value) {
    final newGrid = List.generate(
      size,
      (r) => List.generate(
        size,
        (c) => (r == row && c == col) ? value : _grid[r][c],
        growable: false,
      ),
      growable: false,
    );
    return Board(newGrid);
  }

  /// Returns a list of coordinates (row, col) for all currently empty cells.
  List<(int, int)> get emptyCells {
    final list = <(int, int)>[];
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (_grid[r][c] == 0) {
          list.add((r, c));
        }
      }
    }
    return list;
  }

  /// True if all 16 cells are non-zero.
  bool get isFull => emptyCells.isEmpty;

  /// Count of non-empty cells.
  int get occupiedCount => 16 - emptyCells.length;

  /// Returns the highest tile value currently on the board.
  int get highestTile {
    int maxVal = 0;
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (_grid[r][c] > maxVal) {
          maxVal = _grid[r][c];
        }
      }
    }
    return maxVal;
  }

  /// Returns a deep copy of the grid as standard lists.
  List<List<int>> toMatrix() {
    return List.generate(
      size,
      (r) => List.generate(size, (c) => _grid[r][c]),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Board) return false;
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (_grid[r][c] != other._grid[r][c]) return false;
      }
    }
    return true;
  }

  @override
  int get hashCode {
    int hash = 17;
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        hash = 37 * hash + _grid[r][c];
      }
    }
    return hash;
  }

  @override
  String toString() {
    return _grid.map((row) => row.map((v) => v.toString().padLeft(4)).join(' ')).join('\n');
  }
}
