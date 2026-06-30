class NetworkException implements Exception {
  const NetworkException([this.message = 'No internet connection.']);
  final String message;
}

class ServerException implements Exception {
  const ServerException({this.message = 'Server error.', this.statusCode});
  final String message;
  final int? statusCode;
}

class CacheException implements Exception {
  const CacheException([this.message = 'Local storage error.']);
  final String message;
}

class PermissionException implements Exception {
  const PermissionException([this.message = 'Permission denied.']);
  final String message;
}
