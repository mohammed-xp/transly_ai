import 'package:transly_ai/core/security/token_storage.dart';

class FakeTokenStorage implements TokenStorage {
  FakeTokenStorage({this.accessToken, this.refreshToken});

  String? accessToken;
  String? refreshToken;
  final List<({String accessToken, String? refreshToken})> saves = [];

  @override
  Future<String?> getAccessToken() async => accessToken;

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    saves.add((accessToken: accessToken, refreshToken: refreshToken));
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}
