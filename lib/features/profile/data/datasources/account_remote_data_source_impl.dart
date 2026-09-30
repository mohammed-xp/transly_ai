import '../../../../core/network/api_consumer.dart';
import '../../../../core/network/endpoints.dart';
import 'account_remote_data_source.dart';

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  AccountRemoteDataSourceImpl(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  @override
  Future<void> deleteAccount({required String password}) {
    return _apiConsumer.delete(
      Endpoints.deleteAccount,
      data: {'password': password},
    );
  }
}
