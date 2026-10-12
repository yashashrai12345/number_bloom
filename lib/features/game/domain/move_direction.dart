/// Represents the four orthogonal directions a player can swipe or move.
enum MoveDirection {
  up,
  down,
  left,
  right;

  /// Returns true if this direction moves along the vertical axis.
  bool get isVertical => this == MoveDirection.up || this == MoveDirection.down;

  /// Returns true if this direction moves along the horizontal axis.
  bool get isHorizontal =>
      this == MoveDirection.left || this == MoveDirection.right;
}
