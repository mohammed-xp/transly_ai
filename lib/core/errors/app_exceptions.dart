import '../data/models/error_model.dart';

sealed class AppException implements Exception {
  const AppException({this.statusCode});

  final int? statusCode;
}

class NetworkException extends AppException {
  const NetworkException();
}

class ServerException extends AppException {
  const ServerException({super.statusCode});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException();
}

class ValidationException extends AppException {
  const ValidationException(this.error);

  final ErrorModel error;
}

class NotFoundException extends AppException {
  const NotFoundException();
}

/// Generic 4xx (400, 409, ...) — carries the backend message when present.
class ClientException extends AppException {
  const ClientException({super.statusCode, this.error});

  final ErrorModel? error;
}

/// 429 Too Many Requests or 408 Request Timeout.
class TooManyRequestsException extends AppException {
  const TooManyRequestsException({super.statusCode});
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
