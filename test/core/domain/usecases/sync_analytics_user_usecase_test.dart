import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/domain/usecases/sync_analytics_user_usecase.dart';

import '../../../helpers/fake_analytics_service.dart';
import '../../../helpers/fake_user_repo.dart';

void main() {
  late FakeAnalyticsService analytics;

  setUp(() => analytics = FakeAnalyticsService());

  test('links analytics to the signed-in account id', () async {
    await SyncAnalyticsUserUseCase(FakeUserRepo(testUser), analytics)();

    expect(analytics.userIds, [testUser.id]);
  });

  test('clears the analytics user when nobody is signed in', () async {
    await SyncAnalyticsUserUseCase(FakeUserRepo(), analytics)();

    expect(analytics.userIds, [null]);
  });
}
