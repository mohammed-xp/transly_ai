/// Typed exceptions thrown by data sources. Caught at the repository boundary
/// and mapped to [Failure]s (CLAUDE.md §A-3, §B-5) — never rethrown as-is past
/// the data layer.
sealed class AppException implements Exception {
  const AppException([this.message]);

  final String? message;
}

/// The remote API was unreachable, timed out, or the device has no route to
/// it — distinct from the API itself returning an error.
class RemoteConnectionException extends AppException {
  const RemoteConnectionException([super.message]);
}

/// The remote API responded but the call failed: non-2xx status, a safety
/// block, or a malformed/empty response.
class RemoteApiException extends AppException {
  const RemoteApiException([super.message]);
}
