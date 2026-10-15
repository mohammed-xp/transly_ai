import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/domain/entities/language_entity.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/auto_download_offline_models_usecase.dart';
import 'package:transly_ai/features/translate/domain/entities/translation_engine.dart';
import 'package:transly_ai/features/translate/domain/entities/translation_entity.dart';
import 'package:transly_ai/features/translate/domain/usecases/translate_text_usecase.dart';

import '../../../../helpers/fake_offline_models_repo.dart';
import '../../../../helpers/fake_translation_repo.dart';

void main() {
  late FakeTranslationRepo translations;
  late FakeOfflineModelsRepo models;
  late TranslateTextUseCase translate;

  setUp(() {
    translations = FakeTranslationRepo();
    models = FakeOfflineModelsRepo();
    translate = TranslateTextUseCase(
      translations,
      AutoDownloadOfflineModelsUseCase(models),
    );
  });

  Future<ApiResult<TranslationEntity>> translateHello() => translate(
    text: 'Hello',
    from: LanguageEntity.english,
    to: LanguageEntity.arabic,
    tone: 'formal',
  );

  test('returns the translation', () async {
    final result = await translateHello();

    expect(result, isA<ApiSuccess<TranslationEntity>>());
  });

  test('an online translation auto-downloads both languages', () async {
    await translateHello();
    await pumpEventQueue();

    expect(models.autoDownloads, ['en', 'ar']);
  });

  test('an offline translation downloads nothing', () async {
    translations.engine = TranslationEngine.offline;

    await translateHello();
    await pumpEventQueue();

    expect(models.autoDownloads, isEmpty);
  });

  test('a failed translation downloads nothing', () async {
    translations.translateFailure = const NetworkFailure();

    await translateHello();
    await pumpEventQueue();

    expect(models.autoDownloads, isEmpty);
  });
}
