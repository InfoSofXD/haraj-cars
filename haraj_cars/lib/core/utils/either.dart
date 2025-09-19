/// Either type for handling success and failure cases
abstract class Either<L, R> {
  const Either();

  /// Check if this is a Left (failure) value
  bool get isLeft => this is Left<L, R>;

  /// Check if this is a Right (success) value
  bool get isRight => this is Right<L, R>;

  /// Get the left value if this is Left, otherwise throw
  L get left => (this as Left<L, R>).value;

  /// Get the right value if this is Right, otherwise throw
  R get right => (this as Right<L, R>).value;

  /// Fold over the Either value
  T fold<T>(T Function(L) onLeft, T Function(R) onRight) {
    if (isLeft) {
      return onLeft(left);
    } else {
      return onRight(right);
    }
  }

  /// Map the right value
  Either<L, T> map<T>(T Function(R) f) {
    return fold(
      (left) => Left<L, T>(left),
      (right) => Right<L, T>(f(right)),
    );
  }

  /// Map the left value
  Either<T, R> mapLeft<T>(T Function(L) f) {
    return fold(
      (left) => Left<T, R>(f(left)),
      (right) => Right<T, R>(right),
    );
  }
}

/// Left side of Either (typically represents failure/error)
class Left<L, R> extends Either<L, R> {
  final L value;

  const Left(this.value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Left<L, R> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Left($value)';
}

/// Right side of Either (typically represents success/value)
class Right<L, R> extends Either<L, R> {
  final R value;

  const Right(this.value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Right<L, R> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Right($value)';
}
