import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/api_result.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../domain/entities/language.dart';
import '../../domain/entities/translation_engine.dart';
import '../../domain/entities/translation_entity.dart';
import '../../domain/entities/translation_tone.dart';
import '../../domain/repos/translation_repository.dart';
import '../datasources/translation_local_data_source.dart';
import '../datasources/translation_remote_data_source.dart';

/// Routes translation between the online source (tone-aware, reached when the
/// device is connected) and the offline ML Kit source. When the remote call
/// fails, falls back to the local source so translation stays available; the
/// entity's `engine` field records which one actually produced the result.
///
/// Exceptions are caught at this boundary and mapped to typed [Failure]s
/// (CLAUDE.md §B-5).
class TranslationRepositoryImpl implements TranslationRepository {
  TranslationRepositoryImpl({
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
    required Language from,
    required Language to,
    required TranslationTone tone,
  }) async {
    try {
      if (await _connectivity.isConnected) {
        try {
          final response = await _remote.translate(
            text: text,
            from: from,
            to: to,
            tone: tone,
          );
          return ApiResult.success(
            TranslationEntity(
              sourceText: text,
              translatedText: response.translatedText,
              from: from,
              to: to,
              engine: TranslationEngine.online,
            ),
          );
        } catch (remoteError) {
          try {
            final translated = await _local.translate(text, from, to);
            return ApiResult.success(
              TranslationEntity(
                sourceText: text,
                translatedText: translated,
                from: from,
                to: to,
                engine: TranslationEngine.offline,
              ),
            );
          } catch (_) {
            return ApiResult.failure(_mapRemoteError(remoteError));
          }
        }
      }

      final translated = await _local.translate(text, from, to);
      return ApiResult.success(
        TranslationEntity(
          sourceText: text,
          translatedText: translated,
          from: from,
          to: to,
          engine: TranslationEngine.offline,
        ),
      );
    } catch (e) {
      return ApiResult.failure(TranslationFailure(e.toString()));
    }
  }

  Failure _mapRemoteError(Object error) => switch (error) {
    RemoteConnectionException(:final message) => NoConnectionFailure(message),
    RemoteApiException(:final message) => TranslationFailure(message),
    UnauthorizedException(:final message) => TranslationFailure(message),
    _ => TranslationFailure(error.toString()),
  };

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

  @override
  Stream<bool> watchOnlineAvailability() async* {
    // Connectivity is a platform channel: `checkConnectivity` throws on some
    // Android configurations and the change stream can emit errors. Both are
    // contained here at the data boundary (CLAUDE.md §A-3) and reported as
    // "not available" — an unavailable probe must degrade the tone selector,
    // never surface as an uncaught async error.
    try {
      yield await _connectivity.isConnected;
    } catch (_) {
      yield false;
    }
    yield* _connectivity.onConnectedChanged.handleError((_) {});
  }
}
