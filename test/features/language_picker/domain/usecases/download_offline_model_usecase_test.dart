import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/domain/entities/language_entity.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/services/analytics_event.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/download_offline_model_usecase.dart';

import '../../../../helpers/fake_analytics_service.dart';
import '../../../../helpers/fake_offline_models_repo.dart';

void main() {
  late FakeOfflineModelsRepo models;
  late FakeAnalyticsService analytics;
  late DownloadOfflineModelUseCase download;

  setUp(() {
    models = FakeOfflineModelsRepo();
    analytics = FakeAnalyticsService();
    download = DownloadOfflineModelUseCase(models, analytics);
  });

  test('downloads the language by its code', () async {
    await download(LanguageEntity.arabic);

    expect(models.downloads, ['ar']);
  });

  test('a finished download logs the language', () async {
    await download(LanguageEntity.arabic);

    expect(
      analytics.events.single,
      isA<OfflinePackDownloadEvent>().having(
        (e) => e.language,
        'language',
        'ar',
      ),
    );
  });

  test('a failed download logs nothing', () async {
    models.downloadResult = const ApiResult.failure(ModelDownloadFailure());

    await download(LanguageEntity.arabic);

    expect(analytics.events, isEmpty);
  });
}
