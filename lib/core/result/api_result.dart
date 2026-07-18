import '../errors/failure.dart';

/// Result of an operation that can succeed with a [T] or fail with a [Failure].
/// Sealed so callers exhaustively handle both arms (CLAUDE.md §B-5). Pure Dart.
sealed class ApiResult<T> {
  const ApiResult();

  const factory ApiResult.success(T data) = ApiSuccess<T>;
  const factory ApiResult.failure(Failure failure) = ApiFailure<T>;

  /// Folds both arms into a single [R]. Both handlers are required.
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    return switch (this) {
      ApiSuccess<T>(:final data) => success(data),
      ApiFailure<T>(failure: final f) => failure(f),
    };
  }
}

class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);

  final T data;
}

class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.failure);

  final Failure failure;
}
