import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/domain/entities/language_entity.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/auto_download_offline_models_usecase.dart';

import '../../../../helpers/fake_languages_repo.dart';
import '../../../../helpers/fake_offline_models_repo.dart';

void main() {
  test('asks for each language', () async {
    final models = FakeOfflineModelsRepo();

    await AutoDownloadOfflineModelsUseCase(models)([
      LanguageEntity.arabic,
      testFrench,
    ]);

    expect(models.autoDownloads, ['ar', 'fr']);
  });

  test('asks once for a language listed twice', () async {
    final models = FakeOfflineModelsRepo();

    await AutoDownloadOfflineModelsUseCase(models)([testFrench, testFrench]);

    expect(models.autoDownloads, ['fr']);
  });
}
