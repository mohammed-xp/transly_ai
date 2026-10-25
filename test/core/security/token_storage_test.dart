import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/security/token_storage.dart';

void main() {
  late TokenStorage storage;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    storage = TokenStorage(const FlutterSecureStorage());
  });

  test('saves both tokens and reads them back', () async {
    await storage.saveTokens(
      accessToken: 'access-1',
      refreshToken: 'refresh-1',
    );

    expect(await storage.getAccessToken(), 'access-1');
    expect(await storage.getRefreshToken(), 'refresh-1');
  });

  test(
    'saving without a refresh token drops the previously saved one',
    () async {
      await storage.saveTokens(
        accessToken: 'access-1',
        refreshToken: 'refresh-1',
      );

      await storage.saveTokens(accessToken: 'access-2');

      expect(await storage.getAccessToken(), 'access-2');
      expect(await storage.getRefreshToken(), isNull);
    },
  );

  test(
    'saving with an empty refresh token drops the previously saved one',
    () async {
      await storage.saveTokens(
        accessToken: 'access-1',
        refreshToken: 'refresh-1',
      );

      await storage.saveTokens(accessToken: 'access-2', refreshToken: '');

      expect(await storage.getAccessToken(), 'access-2');
      expect(await storage.getRefreshToken(), isNull);
    },
  );

  test('clear removes both tokens', () async {
    await storage.saveTokens(
      accessToken: 'access-1',
      refreshToken: 'refresh-1',
    );

    await storage.clear();

    expect(await storage.getAccessToken(), isNull);
    expect(await storage.getRefreshToken(), isNull);
  });
}
