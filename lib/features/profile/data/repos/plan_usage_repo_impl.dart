import '../../../../core/errors/error_mapper.dart';
import '../../../../core/result/api_result.dart';
import '../../domain/entities/plan_usage_entity.dart';
import '../../domain/repos/plan_usage_repo.dart';
import '../datasources/plan_usage_remote_data_source.dart';

class PlanUsageRepoImpl implements PlanUsageRepo {
  PlanUsageRepoImpl(this._remote);

  final PlanUsageRemoteDataSource _remote;

  @override
  Future<ApiResult<PlanUsageEntity>> getPlanUsage() async {
    try {
      final usage = await _remote.getPlanUsage();
      return ApiResult.success(usage.toEntity());
    } catch (e) {
      return ApiResult.failure(ErrorMapper.map(e));
    }
  }
}
