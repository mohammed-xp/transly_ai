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
    final data = e.response?.data;

    return switch (status) {
      401 => const UnauthorizedException(),
      404 => const NotFoundException(),
      422 when data is Map => ValidationException(
        ErrorModel.fromJson(Map<String, dynamic>.from(data)),
      ),
      429 || 408 => TooManyRequestsException(statusCode: status),
      final int s when s >= 400 && s < 500 => ClientException(
        statusCode: s,
        error: data is Map
            ? ErrorModel.fromJson(Map<String, dynamic>.from(data))
            : null,
      ),
      _ => ServerException(statusCode: status),
    };
  }

  static Failure mapExceptionToFailure(AppException e) => switch (e) {
    NetworkException() => const NetworkFailure(),
    UnauthorizedException() => const UnauthorizedFailure(),
    ValidationException(:final error) => ValidationFailure(error.toEntity()),
    ServerException(:final statusCode) => ServerFailure(statusCode: statusCode),
    NotFoundException() => const NotFoundFailure(),
    ClientException(:final statusCode, :final error) => ClientFailure(
      statusCode: statusCode,
      error: error?.toEntity(),
    ),
    TooManyRequestsException(:final statusCode) => TooManyRequestsFailure(
      statusCode: statusCode,
    ),
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
