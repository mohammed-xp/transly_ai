import '../error/failures.dart';

sealed class ApiResult<T> {
  const ApiResult();
}

final class Success<T> extends ApiResult<T> {
  const Success(this.data);
  final T data;
}

final class ApiError<T> extends ApiResult<T> {
  const ApiError(this.failure);
  final Failure failure;
}

extension ApiResultX<T> on ApiResult<T> {
  bool get isSuccess => this is Success<T>;
  bool get isError => this is ApiError<T>;

  T? get dataOrNull => switch (this) {
        Success(:final data) => data,
        ApiError() => null,
      };

  Failure? get failureOrNull => switch (this) {
        ApiError(:final failure) => failure,
        Success() => null,
      };

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) error,
  }) =>
      switch (this) {
        Success(:final data) => success(data),
        ApiError(:final failure) => error(failure),
      };
}
