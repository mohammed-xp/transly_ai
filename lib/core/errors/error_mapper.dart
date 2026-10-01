import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';

import '../data/models/error_model.dart';
import 'app_exceptions.dart';
import 'failure.dart';

abstract final class ErrorMapper {
  static AppException mapDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const NetworkException();
    }

    if (e.type != DioExceptionType.badResponse) {
      return const UnknownException();
    }

    final status = e.response?.statusCode;
    final error = _parseError(e.response?.data);

    return switch (status) {
      401 => UnauthorizedException(error: error),
      404 => NotFoundException(error: error),
      422 when error != null => ValidationException(error),
      429 || 408 => TooManyRequestsException(statusCode: status, error: error),
      final int s when s >= 400 && s < 500 => ClientException(
        statusCode: s,
        error: error,
      ),
      _ => ServerException(statusCode: status, error: error),
    };
  }

  /// A body that isn't a JSON object, or doesn't parse, just means there is
  /// no backend error to show.
  static ErrorModel? _parseError(Object? data) {
    if (data is! Map) return null;
    try {
      return ErrorModel.fromJson(Map<String, dynamic>.from(data));
    } catch (_) {
      return null;
    }
  }

  static Failure mapExceptionToFailure(AppException e) => switch (e) {
    NetworkException() => const NetworkFailure(),
    UnauthorizedException(:final error) => UnauthorizedFailure(
      error: error?.toEntity(),
    ),
    ValidationException(:final error) => ValidationFailure(error.toEntity()),
    ServerException(:final statusCode, :final error) => ServerFailure(
      statusCode: statusCode,
      error: error?.toEntity(),
    ),
    NotFoundException(:final error) => NotFoundFailure(
      error: error?.toEntity(),
    ),
    ClientException(:final statusCode, :final error) => ClientFailure(
      statusCode: statusCode,
      error: error?.toEntity(),
    ),
    TooManyRequestsException(:final statusCode, :final error) =>
      TooManyRequestsFailure(statusCode: statusCode, error: error?.toEntity()),
    ParsingException() => const FormatFailure(),
    UnsupportedLanguageException() => const UnsupportedLanguageFailure(),
    UnknownException() => const UnknownFailure(),
  };

  /// Maps any thrown error to a [Failure].
  static Failure map(Object error) {
    if (error is Failure) return error;
    if (error is AppException) return mapExceptionToFailure(error);
    if (error is DioException) {
      return mapExceptionToFailure(mapDioException(error));
    }
    if (error is SocketException) return const NetworkFailure();

    log(error.runtimeType.toString(), name: 'ErrorMapper');
    if (error is FormatException || error is TypeError) {
      return const FormatFailure();
    }
    return const UnknownFailure();
  }
}
