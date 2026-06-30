sealed class Failure {
  const Failure(this.message);
  final String message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error. Please try again.']);
  final int? statusCode = null;
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local storage error.']);
}

final class OfflineFailure extends Failure {
  const OfflineFailure([super.message = 'Offline mode: limited translation available.']);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong.']);
}

final class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission denied.']);
}
