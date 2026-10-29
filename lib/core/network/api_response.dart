/// A JSON response body together with the headers it came with, for the
/// calls whose headers carry data (e.g. the conversation quota).
class ApiResponse {
  const ApiResponse({required this.data, this.headers = const {}});

  final Map<String, dynamic> data;
  final Map<String, List<String>> headers;

  /// The first value of header [name], matched case-insensitively.
  String? header(String name) {
    final key = name.toLowerCase();
    for (final MapEntry(key: headerName, :value) in headers.entries) {
      if (headerName.toLowerCase() == key && value.isNotEmpty) {
        return value.first;
      }
    }
    return null;
  }
}
