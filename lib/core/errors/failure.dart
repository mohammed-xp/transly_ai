import '../domain/entities/error_entity.dart';

sealed class Failure {
  const Failure({this.statusCode, this.error});

  final int? statusCode;

  final ErrorEntity? error;
}

class NetworkFailure extends Failure {
  const NetworkFailure();
}

class ServerFailure extends Failure {
  const ServerFailure({super.statusCode, super.error});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.error});
}

class ValidationFailure extends Failure {
  const ValidationFailure(ErrorEntity error) : super(error: error);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({super.error});
}

/// Generic 4xx (400, 409, ...) — carries the backend error when present.
class ClientFailure extends Failure {
  const ClientFailure({super.statusCode, super.error});
}

/// 429 Too Many Requests or 408 Request Timeout.
class TooManyRequestsFailure extends Failure {
  const TooManyRequestsFailure({super.statusCode, super.error});
}

class FormatFailure extends Failure {
  const FormatFailure();
}

class UnsupportedLanguageFailure extends Failure {
  const UnsupportedLanguageFailure();
}

class ModelDownloadFailure extends Failure {
  const ModelDownloadFailure();
}

class UnknownFailure extends Failure {
  const UnknownFailure();
}
