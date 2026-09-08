import 'package:transly_ai/features/auth/data/models/user_login_model.dart';

import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/rest_client.dart';
import 'auth_remote_data_source.dart';


class ApiAuthRemoteDataSource implements AuthRemoteDataSource {
  ApiAuthRemoteDataSource(this._restClient);

  final RestClient _restClient;

  @override
  Future<UserLoginModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final data = await _restClient.postJson(
        ApiEndpoints.login,
        body: {'email': email, 'password': password},
      );
      return UserLoginModel.fromJson(data);
    } on UnauthorizedException {
      throw const AuthProviderException('invalid-credential');
    } on RemoteApiException catch (e) {
      throw AuthProviderException(_codeForStatus(e.statusCode), e.message);
    }
  }

  String _codeForStatus(int? statusCode) => switch (statusCode) {
    429 => 'too-many-requests',
    403 => 'user-disabled',
    _ => 'unknown',
  };
}
