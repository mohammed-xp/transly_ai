import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/api_result.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../domain/entities/translation_engine.dart';
import '../../domain/entities/translation_entity.dart';
import '../../domain/repos/translation_repo.dart';
import '../datasources/translation_local_data_source.dart';
import '../datasources/translation_remote_data_source.dart';
import '../models/language_model.dart';

/// Online (backend API) when connected, on-device ML Kit when offline. A
/// failed online call surfaces as a failure rather than falling back.
class TranslationRepoImpl implements TranslationRepo {
  TranslationRepoImpl({
    required TranslationLocalDataSource local,
    required ConnectivityService connectivity,
    required TranslationRemoteDataSource remote,
  }) : _local = local,
       _connectivity = connectivity,
       _remote = remote;

  final TranslationLocalDataSource _local;
  final ConnectivityService _connectivity;
  final TranslationRemoteDataSource _remote;

  @override
  Future<ApiResult<TranslationEntity>> translate({
    required String text,
    required LanguageEntity from,
    required LanguageEntity to,
    required String tone,
  }) async {
    try {
      if (await _connectivity.isConnected) {
        final response = await _remote.translate(
          text: text,
          from: from.code,
          to: to.code,
          tone: tone,
        );
        return ApiResult.success(response.toEntity(TranslationEngine.online));
      }

      final translated = await _local.translate(
        text,
        LanguageModel.fromEntity(from),
        LanguageModel.fromEntity(to),
      );
      return ApiResult.success(
        TranslationEntity(
          sourceText: text,
          translatedText: translated,
          from: from,
          to: to,
          model: null,
          engine: TranslationEngine.offline,
        ),
      );
    } catch (e) {
      return ApiResult.failure(ErrorMapper.map(e));
    }
  }

  @override
  Future<ApiResult<bool>> areModelsDownloaded({
    required LanguageEntity from,
    required LanguageEntity to,
  }) async {
    try {
      return ApiResult.success(
        await _local.areModelsDownloaded(
          LanguageModel.fromEntity(from),
          LanguageModel.fromEntity(to),
        ),
      );
    } catch (e) {
      return ApiResult.failure(ErrorMapper.map(e));
    }
  }

  @override
  Future<ApiResult<void>> downloadModels({
    required LanguageEntity from,
    required LanguageEntity to,
  }) async {
    try {
      await _local.downloadModels(
        LanguageModel.fromEntity(from),
        LanguageModel.fromEntity(to),
      );
      return const ApiResult.success(null);
    } catch (e) {
      final failure = ErrorMapper.map(e);
      return ApiResult.failure(
        failure is UnsupportedLanguageFailure
            ? failure
            : const ModelDownloadFailure(),
      );
    }
  }

  @override
  Stream<bool> watchOnlineAvailability() async* {
    try {
      yield await _connectivity.isConnected;
    } catch (_) {
      yield false;
    }
    yield* _connectivity.onConnectedChanged.handleError((_) {});
  }
}
