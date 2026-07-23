import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/errors/app_exceptions.dart';
import 'package:transly_ai/core/network/dio_rest_client.dart';

/// Hand-written fake adapter — no mocking framework in this project. Records
/// the outgoing request and either returns a canned response or throws the
/// [DioException] the test configured, exactly as a real adapter would on a
/// network failure.
class _FakeHttpClientAdapter implements HttpClientAdapter {
  RequestOptions? lastRequest;

  int statusCode = 200;
  Map<String, dynamic> responseJson = const {};
  DioException? throwError;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;

    if (throwError != null) throw throwError!;

    return ResponseBody.fromString(
      jsonEncode(responseJson),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _FakeHttpClientAdapter adapter;
  late Dio dio;
  late DioRestClient client;

  setUp(() {
    adapter = _FakeHttpClientAdapter();
    dio = Dio()..httpClientAdapter = adapter;
    client = DioRestClient(dio);
  });

  group('DioRestClient.postJson', () {
    test('sends Content-Type, extra headers, and the JSON body', () async {
      adapter.responseJson = {'ok': true};

      await client.postJson(
        'https://example.test/endpoint',
        headers: {'x-goog-api-key': 'test-key'},
        body: {'hello': 'world'},
      );

      final request = adapter.lastRequest!;
      expect(request.uri.toString(), 'https://example.test/endpoint');
      expect(request.headers['x-goog-api-key'], 'test-key');
      expect(request.headers['Content-Type'], 'application/json');
      expect(request.data, {'hello': 'world'});
    });

    test('returns the decoded JSON response body', () async {
      adapter.responseJson = {'candidates': ['a', 'b']};

      final result = await client.postJson(
        'https://example.test/endpoint',
        body: {},
      );

      expect(result, {'candidates': ['a', 'b']});
    });

    test('throws RemoteApiException on a non-2xx response', () async {
      adapter.throwError = DioException(
        requestOptions: RequestOptions(path: 'x'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: 'x'),
          statusCode: 429,
        ),
      );

      expect(
        () => client.postJson('https://example.test/endpoint', body: {}),
        throwsA(isA<RemoteApiException>()),
      );
    });

    test('throws RemoteConnectionException on connection timeout', () async {
      adapter.throwError = DioException(
        requestOptions: RequestOptions(path: 'x'),
        type: DioExceptionType.connectionTimeout,
      );

      expect(
        () => client.postJson('https://example.test/endpoint', body: {}),
        throwsA(isA<RemoteConnectionException>()),
      );
    });

    test('throws RemoteConnectionException on connection error', () async {
      adapter.throwError = DioException(
        requestOptions: RequestOptions(path: 'x'),
        type: DioExceptionType.connectionError,
      );

      expect(
        () => client.postJson('https://example.test/endpoint', body: {}),
        throwsA(isA<RemoteConnectionException>()),
      );
    });
  });
}
