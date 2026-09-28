import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
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

void main() {
  PlanUsageRepoImpl repoWithResponse(Map<String, dynamic> response) =>
      PlanUsageRepoImpl(
        PlanUsageRemoteDataSourceImpl(FakeApiConsumer(response)),
      );

  test('reads the usage from the ApiResponse envelope of /usage', () async {
    final api = FakeApiConsumer({
      'success': true,
      'statusCode': 200,
      'message': 'Usage retrieved successfully',
      'data': {
        'plan': 'free',
        'charactersLimit': 5000,
        'charactersUsed': 3500,
        'charactersRemaining': 1500,
        'resetsAt': '2026-09-29T00:00:00+00:00',
      },
    });
    final repo = PlanUsageRepoImpl(PlanUsageRemoteDataSourceImpl(api));

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
    );

    final result = await repo.getPlanUsage();

    expect((result as ApiFailure).failure, isA<ServerFailure>());
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
