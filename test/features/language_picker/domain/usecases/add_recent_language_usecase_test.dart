import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/domain/entities/language_entity.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/add_recent_language_usecase.dart';

import '../../../../helpers/fake_languages_repo.dart';

void main() {
  test('puts the language first', () async {
    final repo = FakeLanguagesRepo(recents: [testGerman]);

    await AddRecentLanguageUseCase(repo)(testFrench);

    expect(repo.recents, [testFrench, testGerman]);
  });

  test('moves a language already in the list to the front', () async {
    final repo = FakeLanguagesRepo(recents: [testGerman, testFrench]);

    await AddRecentLanguageUseCase(repo)(testFrench);

    expect(repo.recents, [testFrench, testGerman]);
  });

  test('keeps only the newest languages', () async {
    final repo = FakeLanguagesRepo(
      recents: [
        for (var i = 0; i < AddRecentLanguageUseCase.maxRecents; i++)
          LanguageEntity(
            code: 'l$i',
            name: 'L$i',
            nativeName: 'L$i',
            isRtl: false,
          ),
      ],
    );

    await AddRecentLanguageUseCase(repo)(testFrench);

    expect(repo.recents, hasLength(AddRecentLanguageUseCase.maxRecents));
    expect(repo.recents.first, testFrench);
    expect(repo.recents.last.code, 'l4');
  });

  test('returns the new list', () async {
    final repo = FakeLanguagesRepo(recents: [testGerman]);

    final result = await AddRecentLanguageUseCase(repo)(testFrench);

    expect((result as ApiSuccess<List<LanguageEntity>>).data, [
      testFrench,
      testGerman,
    ]);
  });

  test('returns the failure when the list cannot be saved', () async {
    final repo = FakeLanguagesRepo(
      saveResult: const ApiResult.failure(UnknownFailure()),
    );

    final result = await AddRecentLanguageUseCase(repo)(testFrench);

    expect(result, isA<ApiFailure<List<LanguageEntity>>>());
  });
}
