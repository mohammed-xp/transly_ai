import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/network/dio_base_api.dart';
import 'package:transly_ai/core/security/token_storage.dart';
import 'package:transly_ai/core/session/session_manager.dart';

class _RecordingAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode({'data': null}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _NoTokens implements TokenStorage {
  @override
  Future<String?> getAccessToken() async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedSession implements SessionManager {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  test('sends the current app language as Accept-Language', () async {
    final adapter = _RecordingAdapter();
    var language = 'ar';
    final api = DioBaseApi(
      Dio()..httpClientAdapter = adapter,
      _NoTokens(),
      _UnusedSession(),
      languageCode: () => language,
    );

    await api.get('https://example.test/a');
    language = 'en';
    await api.get('https://example.test/b');

    expect(adapter.requests.map((r) => r.headers['Accept-Language']), [
      'ar',
      'en',
    ]);
  });
}
