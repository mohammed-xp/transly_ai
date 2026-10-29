import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/network/dio_base_api.dart';
import 'package:transly_ai/core/network/endpoints.dart';
import 'package:transly_ai/core/session/session_manager.dart';

import '../../helpers/fake_logout_repo.dart';
import '../../helpers/fake_token_storage.dart';

const _protectedUrl = 'https://example.test/protected';
const _openUrl = 'https://example.test/open';

typedef _Call = ({String path, Object? authorization, Object? data});

class _AuthAdapter implements HttpClientAdapter {
  final List<_Call> calls = [];

  bool rejectEveryToken = false;
  int refreshStatus = 200;
  Object? refreshBody = {
    'data': {'accessToken': 'new-access', 'refreshToken': 'new-refresh'},
  };
  Completer<void>? refreshGate;

  List<_Call> get refreshCalls =>
      calls.where((c) => c.path == Endpoints.refreshToken).toList();

  List<_Call> get protectedCalls =>
      calls.where((c) => c.path != Endpoints.refreshToken).toList();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final authorization = options.headers['Authorization'];
    calls.add((
      path: options.path,
      authorization: authorization,
      data: options.data,
    ));

    if (options.path == Endpoints.refreshToken) {
      await refreshGate?.future;
      return _json(refreshBody, refreshStatus);
    }
    if (options.path == _openUrl) return _json({'data': 'open'}, 200);
    if (!rejectEveryToken && authorization == 'Bearer new-access') {
      return _json({'data': 'ok'}, 200);
    }
    return _json({'message': 'Unauthorized'}, 401);
  }

  static ResponseBody _json(Object? body, int status) =>
      ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  @override
  void close({bool force = false}) {}
}

class _ErrorObserver extends Interceptor {
  int errors = 0;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    errors++;
    handler.next(err);
  }
}

void main() {
  late _AuthAdapter adapter;
  late FakeTokenStorage tokens;
  late FakeLogoutRepo logoutRepo;
  late SessionManager session;
  late _ErrorObserver errorObserver;
  late DioBaseApi api;

  setUp(() {
    adapter = _AuthAdapter();
    tokens = FakeTokenStorage(
      accessToken: 'old-access',
      refreshToken: 'old-refresh',
    );
    logoutRepo = FakeLogoutRepo();
    session = SessionManager(logoutRepo);
    errorObserver = _ErrorObserver();
    api = DioBaseApi(
      Dio()
        ..httpClientAdapter = adapter
        ..interceptors.add(errorObserver),
      tokens,
      session,
      languageCode: () => 'en',
    );
  });

  Matcher isDioError(int status) => isA<DioException>().having(
    (e) => e.response?.statusCode,
    'statusCode',
    status,
  );

  test('sends a Bearer header with the stored access token', () async {
    await api.get(_openUrl);

    expect(adapter.calls.single.authorization, 'Bearer old-access');
  });

  for (final stored in [null, '']) {
    test('sends no Authorization header when the stored access token is '
        '${stored == null ? 'null' : 'empty'}', () async {
      tokens.accessToken = stored;

      await api.get(_openUrl);

      expect(adapter.calls.single.authorization, isNull);
    });
  }

  test('refreshes on a 401 from a protected endpoint and replays the request '
      'with the new token', () async {
    final result = await api.get(_protectedUrl);

    expect(result, {'data': 'ok'});
    expect(adapter.refreshCalls, hasLength(1));
    expect(adapter.protectedCalls.map((c) => c.authorization), [
      'Bearer old-access',
      'Bearer new-access',
    ]);
  });

  test('a 401 after a completed refresh starts a new refresh', () async {
    await api.get(_protectedUrl);
    tokens.accessToken = 'old-access';

    await api.get(_protectedUrl);

    expect(adapter.refreshCalls, hasLength(2));
  });

  test('sends the stored refresh token in the refresh request', () async {
    await api.get(_protectedUrl);

    expect(adapter.refreshCalls.single.data, {'refreshToken': 'old-refresh'});
  });

  test('saves the refreshed access and refresh tokens', () async {
    await api.get(_protectedUrl);

    expect(tokens.saves, [
      (accessToken: 'new-access', refreshToken: 'new-refresh'),
    ]);
  });

  test('keeps the old refresh token when the refresh reply has none', () async {
    adapter.refreshBody = {
      'data': {'accessToken': 'new-access'},
    };

    await api.get(_protectedUrl);

    expect(tokens.saves, [
      (accessToken: 'new-access', refreshToken: 'old-refresh'),
    ]);
  });

  test('keeps the session authenticated after a successful refresh', () async {
    await api.get(_protectedUrl);

    expect(session.status, SessionStatus.authenticated);
    expect(logoutRepo.calls, 0);
  });

  group('with no refresh token stored', () {
    setUp(() => tokens.refreshToken = null);

    test('does not send a refresh request', () async {
      await expectLater(api.get(_protectedUrl), throwsA(isDioError(401)));

      expect(adapter.refreshCalls, isEmpty);
    });

    test('ends the session as expired', () async {
      await expectLater(api.get(_protectedUrl), throwsA(isDioError(401)));

      expect(session.status, SessionStatus.expired);
      expect(logoutRepo.calls, 1);
    });
  });

  test('a rejected refresh ends the session as expired', () async {
    adapter.refreshStatus = 401;
    adapter.refreshBody = {'message': 'Invalid refresh token'};

    await expectLater(api.get(_protectedUrl), throwsA(isDioError(401)));

    expect(adapter.refreshCalls, hasLength(1));
    expect(tokens.saves, isEmpty);
    expect(session.status, SessionStatus.expired);
  });

  test(
    'a refresh reply without an accessToken ends the session as expired',
    () async {
      adapter.refreshBody = {
        'data': {'refreshToken': 'new-refresh'},
      };

      await expectLater(api.get(_protectedUrl), throwsA(isDioError(401)));

      expect(tokens.saves, isEmpty);
      expect(session.status, SessionStatus.expired);
    },
  );

  for (final (name, url) in [
    ('login', Endpoints.login),
    ('register', Endpoints.register),
    ('Google sign-in', Endpoints.googleLogin),
  ]) {
    test(
      'a 401 from $name does not refresh and leaves the session authenticated',
      () async {
        await expectLater(
          api.post(url, data: {'email': 'a@b.c'}),
          throwsA(isDioError(401)),
        );

        expect(adapter.refreshCalls, isEmpty);
        expect(session.status, SessionStatus.authenticated);
        expect(logoutRepo.calls, 0);
      },
    );
  }

  test(
    'a 401 from delete-account (wrong password) does not refresh and does not '
    'end the session',
    () async {
      await expectLater(
        api.post(Endpoints.deleteAccount, data: {'password': 'wrong'}),
        throwsA(isDioError(401)),
      );

      expect(adapter.refreshCalls, isEmpty);
      expect(session.status, SessionStatus.authenticated);
      expect(logoutRepo.calls, 0);
    },
  );

  test('refreshes only once and passes the error on when the replayed request '
      'is rejected again', () async {
    adapter.rejectEveryToken = true;

    await expectLater(api.get(_protectedUrl), throwsA(isDioError(401)));

    expect(adapter.refreshCalls, hasLength(1));
    expect(adapter.protectedCalls, hasLength(2));
  });

  test('two concurrent 401s share a single refresh request', () async {
    final gate = Completer<void>();
    adapter.refreshGate = gate;

    final first = api.get(_protectedUrl);
    final second = api.get('$_protectedUrl?second=1');
    for (var i = 0; i < 10 && errorObserver.errors < 2; i++) {
      await pumpEventQueue();
    }
    await pumpEventQueue();
    expect(errorObserver.errors, 2);
    expect(adapter.refreshCalls, hasLength(1));

    gate.complete();

    expect(await first, {'data': 'ok'});
    expect(await second, {'data': 'ok'});
    expect(adapter.refreshCalls, hasLength(1));
    expect(tokens.saves, hasLength(1));
  });

  test('replays a multipart request with a fresh copy of its form', () async {
    final form = FormData()..fields.add(const MapEntry('languageA', 'ar'));

    final result = await api.postMultipart(_protectedUrl, formData: form);

    expect(result.data, {'data': 'ok'});
    final sent = adapter.protectedCalls.map((c) => c.data).toList();
    expect(sent, hasLength(2));
    expect(sent.last, isA<FormData>());
    expect(identical(sent.first, sent.last), isFalse);
    expect((sent.last! as FormData).fields, form.fields);
  });

  test('a multipart response carries its headers', () async {
    tokens.accessToken = 'new-access';

    final result = await api.postMultipart(_protectedUrl, formData: FormData());

    expect(result.header('content-type'), Headers.jsonContentType);
  });
}
