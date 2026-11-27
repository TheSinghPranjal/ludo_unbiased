/// The outcome of an operation that can fail without throwing.
sealed class Result<T, E> {
  const Result();

  /// True for [Ok].
  bool get isOk => this is Ok<T, E>;

  /// The value of an [Ok]; throws [StateError] on an [Err].
  T get value => switch (this) {
    Ok<T, E>(:final value) => value,
    Err<T, E>(:final error) => throw StateError('Result is Err: $error'),
  };

  /// The error of an [Err]; throws [StateError] on an [Ok].
  E get error => switch (this) {
    Err<T, E>(:final error) => error,
    Ok<T, E>() => throw StateError('Result is Ok'),
  };
}

/// A successful [Result].
final class Ok<T, E> extends Result<T, E> {
  /// Wraps [value].
  const Ok(this.value);

  @override
  final T value;
}

/// A failed [Result].
final class Err<T, E> extends Result<T, E> {
  /// Wraps [error].
  const Err(this.error);

  @override
  final E error;
}
