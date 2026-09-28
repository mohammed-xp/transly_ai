import '../../../../core/network/api_consumer.dart';
import '../../../../core/network/endpoints.dart';
import '../models/plan_usage_model.dart';
import 'plan_usage_remote_data_source.dart';

class PlanUsageRemoteDataSourceImpl implements PlanUsageRemoteDataSource {
  PlanUsageRemoteDataSourceImpl(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  @override
  Future<PlanUsageModel> getPlanUsage() async {
    final data = await _apiConsumer.get(Endpoints.usage);
    return PlanUsageModel.fromJson(data['data'] as Map<String, dynamic>);
  }
}
