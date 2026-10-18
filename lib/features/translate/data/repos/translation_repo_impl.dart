import '../../../../core/data/datasources/offline_models_data_source.dart';
import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/api_result.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../domain/entities/translation_engine.dart';
import '../../domain/entities/translation_entity.dart';
import '../../domain/entities/tone_catalog.dart';
import '../../domain/repos/translation_repo.dart';
import '../datasources/tones_remote_data_source.dart';
import '../datasources/translation_local_data_source.dart';
import '../datasources/translation_remote_data_source.dart';
import '../datasources/translation_settings_local_data_source.dart';
import '../../../../core/data/models/language_model.dart';

/// Online (backend API) when connected, on-device ML Kit when offline. A
/// failed online call surfaces as a failure rather than falling back.
class TranslationRepoImpl implements TranslationRepo {
  TranslationRepoImpl({
    required TranslationLocalDataSource local,
    required OfflineModelsDataSource models,
    required ConnectivityService connectivity,
    required TranslationRemoteDataSource remote,
    required TonesRemoteDataSource remoteTones,
    required TranslationSettingsLocalDataSource settings,
    required String Function() uiLanguageCode,
  }) : _local = local,
       _models = models,
       _connectivity = connectivity,
       _remote = remote,
       _remoteTones = remoteTones,
       _settings = settings,
       _uiLanguageCode = uiLanguageCode;

  final TranslationLocalDataSource _local;
  final OfflineModelsDataSource _models;
  final ConnectivityService _connectivity;
  final TranslationRemoteDataSource _remote;
  final TonesRemoteDataSource _remoteTones;
  final TranslationSettingsLocalDataSource _settings;

  /// The language the server names tones in (sent as `Accept-Language`).
  final String Function() _uiLanguageCode;

  @override
  Future<ApiResult<TranslationEntity>> translate({
    required String text,
    required LanguageEntity from,
    required LanguageEntity to,
    required String? tone,
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

      final missingModel = await _offlineModelFailure(from.code, to.code);
      if (missingModel != null) return ApiResult.failure(missingModel);

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

  /// Checked up front: ML Kit would otherwise try to download a missing model
  /// itself, which can't work offline.
  Future<Failure?> _offlineModelFailure(String from, String to) async {
    for (final code in {from, to}) {
      if (!_models.isSupported(code)) return const UnsupportedLanguageFailure();
      if (_models.isBuiltIn(code)) continue;
      if (!await _models.isDownloaded(code)) {
        return const OfflineModelMissingFailure();
      }
    }
    return null;
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

  /// A cache that can't be read counts as none.
  @override
  ToneCatalog? getCachedTones() {
    try {
      return _settings.getCachedTones()?.toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ApiResult<ToneCatalog>> syncTones() async {
    try {
      final language = _uiLanguageCode();
      final tones = await _remoteTones.getTones();
      // A reply named in a language the UI has since left must not replace
      // the cache: the newer request's reply belongs there.
      if (language == _uiLanguageCode()) {
        // A list that can't be cached is still the right answer for this call.
        try {
          await _settings.cacheTones(tones);
        } catch (_) {}
      }
      return ApiResult.success(tones.toEntity());
    } catch (e) {
      return ApiResult.failure(ErrorMapper.map(e));
    }
  }

  /// A box that can't be read counts as nothing saved.
  @override
  String? getSavedToneCode() {
    try {
      return _settings.getToneCode();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ApiResult<void>> saveToneCode(String code) async {
    try {
      await _settings.saveToneCode(code);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorMapper.map(e));
    }
  }
}
