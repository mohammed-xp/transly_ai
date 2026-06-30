import '../../../../core/domain/entities/language.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/api_result.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../domain/entities/translation.dart';
import '../../domain/repositories/translation_repository.dart';
import '../datasources/ai_translation_stub_datasource.dart';
import '../datasources/mlkit_translation_datasource.dart';

final class TranslationRepositoryImpl implements TranslationRepository {
  const TranslationRepositoryImpl({
    required this.mlKit,
    required this.aiStub,
    required this.connectivity,
  });

  final MlKitTranslationDatasource mlKit;
  final AiTranslationStubDatasource aiStub;
  final ConnectivityService connectivity;

  @override
  Future<ApiResult<Translation>> translate(TranslationRequest request) async {
    try {
      final online = await connectivity.isOnline;
      // Use AI when online, fall back to ML Kit offline
      final translation = online
          ? await aiStub.translate(request)
          : await mlKit.translate(request);
      return Success(translation);
    } on NetworkException catch (e) {
      return ApiError(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return ApiError(ServerFailure(e.message));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<List<Language>>> supportedLanguages() async =>
      Success(Language.wellKnown);
}
