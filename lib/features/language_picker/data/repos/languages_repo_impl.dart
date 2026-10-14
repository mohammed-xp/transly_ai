import 'dart:convert';

import '../../../../core/data/models/language_model.dart';
import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/result/api_result.dart';
import '../../domain/entities/language_pair.dart';
import '../../domain/repos/languages_repo.dart';
import '../datasources/languages_local_data_source.dart';
import '../datasources/languages_remote_data_source.dart';

class LanguagesRepoImpl implements LanguagesRepo {
  const LanguagesRepoImpl({
    required LanguagesRemoteDataSource remote,
    required LanguagesLocalDataSource local,
  }) : _remote = remote,
       _local = local;

  final LanguagesRemoteDataSource _remote;
  final LanguagesLocalDataSource _local;

  /// A cache that can't be read counts as none.
  @override
  List<LanguageEntity> getCachedLanguages() =>
      _toEntities(_cachedLanguages() ?? const []);

  @override
  Future<ApiResult<List<LanguageEntity>>> syncLanguages() async {
    try {
      final languages = await _remote.getLanguages();
      if (!_matchesCache(languages)) {
        // A list that can't be cached is still the right answer for this call.
        try {
          await _local.cacheLanguages(languages);
        } catch (_) {}
      }
      return ApiResult.success(_toEntities(languages));
    } catch (e) {
      return ApiResult.failure(ErrorMapper.map(e));
    }
  }

  /// A pair that can't be read falls back to the default one.
  @override
  LanguagePair getSavedPair() {
    try {
      final pair = _local.getSavedPair();
      if (pair != null) {
        return (from: pair.from.toEntity(), to: pair.to.toEntity());
      }
    } catch (_) {}
    return (
      from: LanguageEntity.defaultSource,
      to: LanguageEntity.defaultTarget,
    );
  }

  @override
  Future<ApiResult<void>> savePair(LanguagePair pair) async {
    try {
      await _local.savePair(
        LanguageModel.fromEntity(pair.from),
        LanguageModel.fromEntity(pair.to),
      );
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorMapper.map(e));
    }
  }

  /// Recents that can't be read count as none.
  @override
  List<LanguageEntity> getRecentLanguages() {
    try {
      return _toEntities(_local.getRecentLanguages());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<ApiResult<void>> saveRecentLanguages(
    List<LanguageEntity> languages,
  ) async {
    try {
      await _local.saveRecentLanguages([
        for (final language in languages) LanguageModel.fromEntity(language),
      ]);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorMapper.map(e));
    }
  }

  List<LanguageModel>? _cachedLanguages() {
    try {
      return _local.getCachedLanguages();
    } catch (_) {
      return null;
    }
  }

  bool _matchesCache(List<LanguageModel> languages) {
    final cached = _cachedLanguages();
    return cached != null && _encode(cached) == _encode(languages);
  }

  String _encode(List<LanguageModel> languages) =>
      jsonEncode([for (final language in languages) language.toJson()]);

  List<LanguageEntity> _toEntities(List<LanguageModel> models) => [
    for (final model in models) model.toEntity(),
  ];
}
