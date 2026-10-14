import 'package:transly_ai/core/domain/entities/language_entity.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/language_picker/domain/entities/language_pair.dart';
import 'package:transly_ai/features/language_picker/domain/repos/languages_repo.dart';

const testGerman = LanguageEntity(
  code: 'de',
  name: 'German',
  nativeName: 'Deutsch',
  isRtl: false,
);

const testFrench = LanguageEntity(
  code: 'fr',
  name: 'French',
  nativeName: 'Français',
  isRtl: false,
);

const testLanguages = [
  LanguageEntity.arabic,
  LanguageEntity.english,
  testGerman,
  testFrench,
];

class FakeLanguagesRepo implements LanguagesRepo {
  FakeLanguagesRepo({
    this.cached = const [],
    this.syncResult = const ApiResult.success(testLanguages),
    this.savedPair = (
      from: LanguageEntity.defaultSource,
      to: LanguageEntity.defaultTarget,
    ),
    this.recents = const [],
    this.saveResult = const ApiResult.success(null),
  });

  List<LanguageEntity> cached;
  ApiResult<List<LanguageEntity>> syncResult;
  int syncCalls = 0;
  LanguagePair savedPair;
  List<LanguageEntity> recents;
  ApiResult<void> saveResult;
  int savePairCalls = 0;

  @override
  List<LanguageEntity> getCachedLanguages() => cached;

  @override
  Future<ApiResult<List<LanguageEntity>>> syncLanguages() async {
    syncCalls++;
    final result = syncResult;
    if (result is ApiSuccess<List<LanguageEntity>>) cached = result.data;
    return result;
  }

  @override
  LanguagePair getSavedPair() => savedPair;

  @override
  Future<ApiResult<void>> savePair(LanguagePair pair) async {
    savePairCalls++;
    if (saveResult is ApiSuccess<void>) savedPair = pair;
    return saveResult;
  }

  @override
  List<LanguageEntity> getRecentLanguages() => recents;

  @override
  Future<ApiResult<void>> saveRecentLanguages(
    List<LanguageEntity> languages,
  ) async {
    if (saveResult is ApiSuccess<void>) recents = languages;
    return saveResult;
  }
}
