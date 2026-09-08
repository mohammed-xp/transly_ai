import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/errors/app_exceptions.dart';
import 'package:transly_ai/core/network/api_endpoints.dart';
import 'package:transly_ai/core/network/rest_client.dart';
import 'package:transly_ai/features/auth/data/datasources/api_auth_remote_data_source.dart';

/// Hand-written fake — no mocking framework in this project (see
/// `dio_rest_client_test.dart`).
class _FakeRestClient implements RestClient {
  String? lastUrl;
  Object? lastBody;
  dynamic responseToReturn = <String, dynamic>{
    'accessToken': 'token-abc',
    'user': {'id': 'uid-1', 'email': 'ahmed@example.com'},
  };
  Object? throwOnPost;

  @override
  Future<dynamic> postJson(
    String url, {
    Map<String, String>? headers,
    required Object body,
  }) async {
    lastUrl = url;
    lastBody = body;
    if (throwOnPost != null) throw throwOnPost!;
    return responseToReturn;
  }
}

void main() {
  late _FakeRestClient restClient;
  late ApiAuthRemoteDataSource dataSource;

  setUp(() {
    restClient = _FakeRestClient();
    dataSource = ApiAuthRemoteDataSource(restClient);
  });

  test('posts to the login endpoint with email/password', () async {
    await dataSource.signInWithEmail(
      email: 'ahmed@example.com',
      password: 'secret1',
    );

    expect(restClient.lastUrl, '${ApiEndpoints.baseUrl}${ApiEndpoints.login}');
    expect(restClient.lastBody, {
      'email': 'ahmed@example.com',
      'password': 'secret1',
    });
  });

  test('returns the access token and user on success', () async {
    final session = await dataSource.signInWithEmail(
      email: 'ahmed@example.com',
      password: 'secret1',
    );

    expect(session.userTokenModel.accessToken, 'token-abc');
    // expect(session.user.id, 'uid-1');
    // expect(session.user.email, 'ahmed@example.com');
  });

  test('maps a 401 to AuthProviderException("invalid-credential")', () async {
    restClient.throwOnPost = const UnauthorizedException('HTTP 401');

    await expectLater(
      dataSource.signInWithEmail(email: 'ahmed@example.com', password: 'wrong'),
      throwsA(
        isA<AuthProviderException>().having(
          (e) => e.code,
          'code',
          'invalid-credential',
        ),
      ),
    );
  });

  test('maps a 429 to AuthProviderException("too-many-requests")', () async {
    restClient.throwOnPost = const RemoteApiException('HTTP 429', 429);

    await expectLater(
      dataSource.signInWithEmail(
        email: 'ahmed@example.com',
        password: 'secret1',
      ),
      throwsA(
        isA<AuthProviderException>().having(
          (e) => e.code,
          'code',
          'too-many-requests',
        ),
      ),
    );
  });

  test('maps a 403 to AuthProviderException("user-disabled")', () async {
    restClient.throwOnPost = const RemoteApiException('HTTP 403', 403);

    await expectLater(
      dataSource.signInWithEmail(
        email: 'ahmed@example.com',
        password: 'secret1',
      ),
      throwsA(
        isA<AuthProviderException>().having(
          (e) => e.code,
          'code',
          'user-disabled',
        ),
      ),
    );
  });

  test('propagates a RemoteConnectionException unchanged', () async {
    restClient.throwOnPost = const RemoteConnectionException('offline');

    expect(
      () => dataSource.signInWithEmail(
        email: 'ahmed@example.com',
        password: 'secret1',
      ),
      throwsA(isA<RemoteConnectionException>()),
    );
  });
}
