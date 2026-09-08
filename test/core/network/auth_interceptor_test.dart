import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/network/api_endpoints.dart';
import 'package:transly_ai/core/network/auth_interceptor.dart';
import 'package:transly_ai/core/session/session_manager.dart';

/// Hand-written fake adapter — no mocking framework in this project. Mirrors
/// the pattern in `dio_rest_client_test.dart`: returns a canned status code
/// and lets Dio's own status validation raise the [DioException].
class _FakeHttpClientAdapter implements HttpClientAdapter {
  RequestOptions? lastRequest;
  int statusCode = 200;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      jsonEncode(<String, dynamic>{}),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _FakeSessionManager implements SessionManager {
  String? _token;
  bool expireCalled = false;

  final _expiredController = StreamController<void>.broadcast();

  @override
  String? get token => _token;

  @override
  Future<void> restore() async {}

  @override
  Future<void> save(String token) async => _token = token;

  @override
  Future<void> clear() async => _token = null;

  @override
  Future<void> expire() async {
    expireCalled = true;
    _token = null;
    _expiredController.add(null);
  }

  @override
  Stream<void> get onExpired => _expiredController.stream;
}

void main() {
  late _FakeHttpClientAdapter adapter;
  late _FakeSessionManager session;
  late Dio dio;

  setUp(() {
    adapter = _FakeHttpClientAdapter();
    session = _FakeSessionManager();
    dio = Dio()
      ..httpClientAdapter = adapter
      ..interceptors.add(AuthInterceptor(session));
  });

  group('AuthInterceptor.onRequest', () {
    test('attaches the Authorization header when a token is present', () async {
      session._token = 'abc123';

      await dio.get<dynamic>('https://example.test/endpoint');

      expect(adapter.lastRequest!.headers['Authorization'], 'Bearer abc123');
    });

    test(
      'does not attach an Authorization header when there is no token',
      () async {
        await dio.get<dynamic>('https://example.test/endpoint');

        expect(
          adapter.lastRequest!.headers.containsKey('Authorization'),
          isFalse,
        );
      },
    );
  });

  group('AuthInterceptor.onError', () {
    test('expires the session on a 401 response', () async {
      adapter.statusCode = 401;

      await expectLater(
        dio.get<dynamic>('https://example.test/endpoint'),
        throwsA(isA<DioException>()),
      );

      expect(session.expireCalled, isTrue);
    });

    test('does not expire the session on a non-401 error response', () async {
      adapter.statusCode = 500;

      await expectLater(
        dio.get<dynamic>('https://example.test/endpoint'),
        throwsA(isA<DioException>()),
      );

      expect(session.expireCalled, isFalse);
    });

    test('does not expire the session on a 401 from the login endpoint '
        '(wrong credentials, not an expired session)', () async {
      adapter.statusCode = 401;

      await expectLater(
        dio.get<dynamic>('${ApiEndpoints.baseUrl}${ApiEndpoints.login}'),
        throwsA(isA<DioException>()),
      );

      expect(session.expireCalled, isFalse);
    });
  });
}
