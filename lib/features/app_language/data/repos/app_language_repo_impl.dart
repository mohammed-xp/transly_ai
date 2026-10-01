import '../../../../core/errors/error_mapper.dart';
import '../../../../core/result/api_result.dart';
import '../../domain/entities/app_language.dart';
import '../../domain/repos/app_language_repo.dart';
import '../datasources/app_language_local_data_source.dart';

class AppLanguageRepoImpl implements AppLanguageRepo {
  const AppLanguageRepoImpl(this._dataSource, {required this.supportedCodes});

  final AppLanguageLocalDataSource _dataSource;

  /// Codes of the languages the app has translations for.
  final Set<String> supportedCodes;

  /// A saved language the app no longer supports, or a box that can't be
  /// read, falls back to the device language.
  @override
  AppLanguage getLanguage() {
    try {
      final code = _dataSource.getLanguageCode();
      if (code == null || !supportedCodes.contains(code)) {
        return AppLanguage.device;
      }
      return AppLanguage(code);
    } catch (_) {
      return AppLanguage.device;
    }
  }

  @override
  Future<ApiResult<void>> saveLanguage(AppLanguage language) async {
    try {
      await _dataSource.saveLanguageCode(language.code);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorMapper.map(e));
    }
  }
}
