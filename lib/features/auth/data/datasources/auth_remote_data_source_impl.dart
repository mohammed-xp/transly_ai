import '../../../../core/network/api_consumer.dart';
import '../../../../core/network/endpoints.dart';
import '../models/user_login_model.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  @override
  Future<UserLoginModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final data = await _apiConsumer.post(
      Endpoints.login,
      data: {'email': email, 'password': password},
    );
    return UserLoginModel.fromJson(data['data']);
  }

  @override
  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    await _apiConsumer.post(
      Endpoints.register,
      data: {'email': email, 'userName': name, 'password': password},
    );
  }
}
