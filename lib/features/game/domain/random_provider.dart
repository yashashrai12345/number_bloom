import 'dart:math' as math;

/// Abstract interface for generating random numbers to ensure testability.
abstract class RandomProvider {
  /// Generates a non-negative random integer uniformly distributed in the range
  /// from 0, inclusive, to [max], exclusive.
  int nextInt(int max);

  /// Generates a non-negative random floating point value uniformly distributed
  /// in the range from 0.0, inclusive, to 1.0, exclusive.
  double nextDouble();
}

/// Standard production provider using [dart:math.Random].
class DefaultRandomProvider implements RandomProvider {
  final math.Random _random;

  DefaultRandomProvider([math.Random? random])
      : _random = random ?? math.Random();

  @override
  int nextInt(int max) => _random.nextInt(max);

  @override
  double nextDouble() => _random.nextDouble();
}

/// Deterministic provider for repeatable unit tests and soak testing.
class DeterministicRandomProvider implements RandomProvider {
  final List<int> _intValues;
  final List<double> _doubleValues;
  int _intIndex = 0;
  int _doubleIndex = 0;

  DeterministicRandomProvider({
    List<int>? intValues,
    List<double>? doubleValues,
  })  : _intValues = intValues ?? [],
        _doubleValues = doubleValues ?? [];

  @override
  int nextInt(int max) {
    if (_intValues.isEmpty) return 0;
    final val = _intValues[_intIndex % _intValues.length];
    _intIndex++;
    return val % max;
  }

  @override
  double nextDouble() {
    if (_doubleValues.isEmpty) return 0.0;
    final val = _doubleValues[_doubleIndex % _doubleValues.length];
    _doubleIndex++;
    return val;
  }
}
