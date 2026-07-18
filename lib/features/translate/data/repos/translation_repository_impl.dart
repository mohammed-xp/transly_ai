import '../../../../core/errors/failure.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/result/api_result.dart';
import '../../domain/entities/language.dart';
import '../../domain/entities/translation_entity.dart';
import '../../domain/entities/translation_tone.dart';
import '../../domain/repos/translation_repository.dart';
import '../datasources/translation_local_data_source.dart';
import '../datasources/translation_remote_data_source.dart';

/// Routes translation between the online source (tone-aware, when a [remote] is
/// configured and the device is connected) and the offline ML Kit source. In
/// this phase [remote] is null, so it always uses the local source — but adding
/// Gemini is a constructor argument plus one DI line, with no signature change.
///
/// Exceptions are caught at this boundary and mapped to typed [Failure]s
/// (CLAUDE.md §B-5).
class TranslationRepositoryImpl implements TranslationRepository {
  TranslationRepositoryImpl({
    required TranslationLocalDataSource local,
    required ConnectivityService connectivity,
    TranslationRemoteDataSource? remote,
  })  : _local = local,
        _connectivity = connectivity,
        _remote = remote;

  final TranslationLocalDataSource _local;
  final ConnectivityService _connectivity;
  final TranslationRemoteDataSource? _remote;

  @override
  Future<ApiResult<TranslationEntity>> translate({
    required String text,
    required Language from,
    required Language to,
    required TranslationTone tone,
  }) async {
    try {
      final remote = _remote;
      final String translated;
      if (remote != null && await _connectivity.isConnected) {
        translated =
            await remote.translate(text: text, from: from, to: to, tone: tone);
      } else {
        translated = await _local.translate(text, from, to);
      }
      return ApiResult.success(
        TranslationEntity(
          sourceText: text,
          translatedText: translated,
          from: from,
          to: to,
        ),
      );
    } catch (e) {
      return ApiResult.failure(TranslationFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<bool>> areModelsDownloaded({
    required Language from,
    required Language to,
  }) async {
    try {
      return ApiResult.success(await _local.areModelsDownloaded(from, to));
    } catch (e) {
      return ApiResult.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> downloadModels({
    required Language from,
    required Language to,
  }) async {
    try {
      await _local.downloadModels(from, to);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ModelDownloadFailure(e.toString()));
    }
  }
}
