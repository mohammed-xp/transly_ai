import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/data/datasources/user_local_data_source.dart';
import 'package:transly_ai/core/data/models/user_model.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/network/endpoints.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/profile/data/datasources/plan_usage_remote_data_source.dart';
import 'package:transly_ai/features/profile/data/datasources/plan_usage_remote_data_source_impl.dart';
import 'package:transly_ai/features/profile/data/models/plan_usage_model.dart';
import 'package:transly_ai/features/profile/data/repos/plan_usage_repo_impl.dart';
import 'package:transly_ai/features/profile/domain/entities/plan_usage_entity.dart';

import '../../../../helpers/fake_api_consumer.dart';

class _ThrowingDataSource implements PlanUsageRemoteDataSource {
  _ThrowingDataSource(this.error);

  final Object error;

  @override
  Future<PlanUsageModel> getPlanUsage() async => throw error;
}

class _FakeUserLocal implements UserLocalDataSource {
  _FakeUserLocal({
    this.plan,
    this.signedIn = true,
    this.failOnRead = false,
    this.failOnWrite = false,
  });

  String? plan;
  final bool signedIn;
  final bool failOnRead;
  final bool failOnWrite;

  @override
  UserModel? getCachedUserData() => signedIn
      ? UserModel(
          id: 'user-1',
          email: 'ahmed.hassan@gmail.com',
          username: 'Ahmed Hassan',
          createdAt: DateTime.utc(2026, 1, 1),
        )
      : null;

  @override
  Future<void> cachePlan(String plan) async {
    if (failOnWrite) throw StateError('box closed');
    this.plan = plan;
  }

  @override
  String? getCachedPlan() {
    if (failOnRead) throw StateError('box closed');
    return plan;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

Map<String, dynamic> _usageResponse(String plan) => {
  'success': true,
  'statusCode': 200,
  'message': 'Usage retrieved successfully',
  'data': {
    'plan': plan,
    'charactersLimit': 5000,
    'charactersUsed': 3500,
    'charactersRemaining': 1500,
    'resetsAt': '2026-09-29T00:00:00+00:00',
  },
};

void main() {
  PlanUsageRepoImpl repoWithResponse(
    Map<String, dynamic> response, {
    _FakeUserLocal? userLocal,
  }) => PlanUsageRepoImpl(
    PlanUsageRemoteDataSourceImpl(FakeApiConsumer(response)),
    userLocal ?? _FakeUserLocal(),
  );

  test('reads the usage from the ApiResponse envelope of /usage', () async {
    final api = FakeApiConsumer(_usageResponse('free'));
    final repo = PlanUsageRepoImpl(
      PlanUsageRemoteDataSourceImpl(api),
      _FakeUserLocal(),
    );

    final result = await repo.getPlanUsage();

    expect(api.requestedUrls, [Endpoints.usage]);
    final usage = (result as ApiSuccess<PlanUsageEntity>).data;
    expect(usage.usedPercent, 70);
    expect(usage.resetsAt, DateTime.utc(2026, 9, 29));
  });

  test('maps a 5xx response to ServerFailure', () async {
    final request = RequestOptions(path: Endpoints.usage);
    final repo = PlanUsageRepoImpl(
      _ThrowingDataSource(
        DioException(
          requestOptions: request,
          type: DioExceptionType.badResponse,
          response: Response(requestOptions: request, statusCode: 500),
        ),
      ),
      _FakeUserLocal(),
    );

    final result = await repo.getPlanUsage();

    expect((result as ApiFailure).failure, isA<ServerFailure>());
  });

  test('caches the plan of a fetched usage', () async {
    final userLocal = _FakeUserLocal();
    final repo = repoWithResponse(
      _usageResponse('pro_monthly'),
      userLocal: userLocal,
    );

    await repo.getPlanUsage();

    expect(userLocal.plan, 'pro_monthly');
  });

  test('does not cache a plan fetched for a user who signed out', () async {
    final userLocal = _FakeUserLocal(signedIn: false);
    final repo = repoWithResponse(
      _usageResponse('pro_monthly'),
      userLocal: userLocal,
    );

    final result = await repo.getPlanUsage();

    expect(result, isA<ApiSuccess<PlanUsageEntity>>());
    expect(userLocal.plan, isNull);
  });

  test('keeps the cached plan when the fetch fails', () async {
    final userLocal = _FakeUserLocal(plan: 'pro_monthly');
    final repo = repoWithResponse({'success': true}, userLocal: userLocal);

    await repo.getPlanUsage();

    expect(userLocal.plan, 'pro_monthly');
  });

  test('returns the usage even when caching the plan fails', () async {
    final repo = repoWithResponse(
      _usageResponse('free'),
      userLocal: _FakeUserLocal(failOnWrite: true),
    );

    final result = await repo.getPlanUsage();

    expect(result, isA<ApiSuccess<PlanUsageEntity>>());
  });

  test('getCachedPlan returns the cached plan', () {
    final repo = repoWithResponse(
      _usageResponse('free'),
      userLocal: _FakeUserLocal(plan: 'pro_monthly'),
    );

    expect(repo.getCachedPlan(), 'pro_monthly');
  });

  test('getCachedPlan is null when nothing is cached', () {
    final repo = repoWithResponse(_usageResponse('free'));

    expect(repo.getCachedPlan(), isNull);
  });

  test('getCachedPlan is null when storage throws', () {
    final repo = repoWithResponse(
      _usageResponse('free'),
      userLocal: _FakeUserLocal(failOnRead: true),
    );

    expect(repo.getCachedPlan(), isNull);
  });

  test('maps an unexpected response shape to FormatFailure', () async {
    final repo = repoWithResponse({
      'data': {'plan': 'free'},
    });

    final result = await repo.getPlanUsage();

    expect((result as ApiFailure).failure, isA<FormatFailure>());
  });

  test('maps a response without data to FormatFailure', () async {
    final repo = repoWithResponse({'success': true});

    final result = await repo.getPlanUsage();

    expect((result as ApiFailure).failure, isA<FormatFailure>());
  });
}
