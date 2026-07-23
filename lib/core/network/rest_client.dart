/// Thin abstraction over an HTTP client so data sources can be unit-tested
/// without a real network stack, and so the data layer never depends on a
/// specific HTTP package directly (CLAUDE.md §A-1, §A-2).
///
/// Throws [RemoteConnectionException] on transport failure/timeout and
/// [RemoteApiException] on a non-2xx response — see `core/errors/app_exceptions.dart`.
abstract class RestClient {
  /// POSTs [body] as JSON to [url] with optional extra [headers], returning
  /// the decoded JSON response body.
  Future<dynamic> postJson(
    String url, {
    Map<String, String>? headers,
    required Object body,
  });
}
