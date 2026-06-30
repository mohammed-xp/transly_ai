import '../../../../core/domain/entities/language.dart';
import '../../../../core/result/api_result.dart';
import '../entities/translation.dart';

abstract interface class TranslationRepository {
  Future<ApiResult<Translation>> translate(TranslationRequest request);
  Future<ApiResult<List<Language>>> supportedLanguages();
}
