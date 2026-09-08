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
/// block, or a malformed/empty response. [statusCode] is null for failures
/// with no HTTP status (e.g. a malformed response body).
class RemoteApiException extends AppException {
  const RemoteApiException([super.message, this.statusCode]);

  final int? statusCode;
}

/// The backend rejected the request with HTTP 401 — the session token is
/// missing, invalid, or expired. Distinct from [RemoteApiException] so
/// callers can react to it specifically (e.g. sign the user out).
class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message]);
}

/// An auth provider rejected the request. Carries a provider-agnostic error
/// [code] (e.g. `invalid-credential`) so the repository can map it to a
/// specific [Failure] without HTTP/provider details leaking past the data
/// layer.
class AuthProviderException extends AppException {
  const AuthProviderException(this.code, [super.message]);

  final String code;
}
