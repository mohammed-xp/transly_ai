import '../data/models/error_model.dart';

sealed class AppException implements Exception {
  const AppException({this.statusCode, this.error});

  final int? statusCode;

  /// The parsed error body, when the backend sent one.
  final ErrorModel? error;
}

class NetworkException extends AppException {
  const NetworkException();
}

class ServerException extends AppException {
  const ServerException({super.statusCode, super.error});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({super.error});
}

class ValidationException extends AppException {
  const ValidationException(ErrorModel error)
    : _error = error,
      super(error: error);

  final ErrorModel _error;

  /// Always present: a 422 is only mapped here when its body parsed.
  @override
  ErrorModel get error => _error;
}

class NotFoundException extends AppException {
  const NotFoundException({super.error});
}

/// Generic 4xx (400, 409, ...) — carries the backend error when present.
class ClientException extends AppException {
  const ClientException({super.statusCode, super.error});
}

/// 429 Too Many Requests or 408 Request Timeout.
class TooManyRequestsException extends AppException {
  const TooManyRequestsException({super.statusCode, super.error});
}

class ParsingException extends AppException {
  const ParsingException();
}

/// The on-device (ML Kit) engine has no model for the requested language.
class UnsupportedLanguageException extends AppException {
  const UnsupportedLanguageException();
}

class UnknownException extends AppException {
  const UnknownException();
}
