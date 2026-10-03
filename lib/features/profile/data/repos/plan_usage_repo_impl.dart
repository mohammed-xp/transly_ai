import '../../../../core/data/datasources/user_local_data_source.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/result/api_result.dart';
import '../../domain/entities/plan_usage_entity.dart';
import '../../domain/repos/plan_usage_repo.dart';
import '../datasources/plan_usage_remote_data_source.dart';

class PlanUsageRepoImpl implements PlanUsageRepo {
  PlanUsageRepoImpl(this._remote, this._userLocal);

  final PlanUsageRemoteDataSource _remote;
  final UserLocalDataSource _userLocal;

  @override
  Future<ApiResult<PlanUsageEntity>> getPlanUsage() async {
    try {
      final usage = await _remote.getPlanUsage();
      await _cachePlan(usage.plan);
      return ApiResult.success(usage.toEntity());
    } catch (e) {
      return ApiResult.failure(ErrorMapper.map(e));
    }
  }

  /// A plan that can't be read is treated as not cached yet.
  @override
  String? getCachedPlan() {
    try {
      return _userLocal.getCachedPlan();
    } catch (_) {
      return null;
    }
  }

  /// The cache only backs the plan shown before the next fetch, so a failed
  /// write must not fail a usage that was fetched fine. Skipped once the user
  /// signed out mid-request — the plan would outlive its session.
  Future<void> _cachePlan(String plan) async {
    try {
      if (_userLocal.getCachedUserData() == null) return;
      await _userLocal.cachePlan(plan);
    } catch (_) {}
  }
}
