import '../../../../core/network/api_consumer.dart';
import '../../../../core/network/endpoints.dart';
import '../models/tone_catalog_model.dart';
import 'tones_remote_data_source.dart';

class TonesRemoteDataSourceImpl implements TonesRemoteDataSource {
  TonesRemoteDataSourceImpl(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  @override
  Future<ToneCatalogModel> getTones() async {
    final data = await _apiConsumer.get(Endpoints.tones);
    return ToneCatalogModel.fromJson(data['data'] as Map<String, dynamic>);
  }
}
