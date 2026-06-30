import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/api_result.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_local_datasource.dart';

final class HistoryRepositoryImpl implements HistoryRepository {
  const HistoryRepositoryImpl(this._datasource);

  final HistoryLocalDatasource _datasource;

  @override
  Future<ApiResult<List<HistoryEntry>>> getAll() => _wrap(() => _datasource.getAll());

  @override
  Future<ApiResult<List<HistoryEntry>>> search(String query) =>
      _wrap(() => _datasource.search(query));

  @override
  Future<ApiResult<void>> save(HistoryEntry entry) =>
      _wrap(() => _datasource.insert(entry));

  @override
  Future<ApiResult<void>> toggleFavorite(int id) =>
      _wrap(() => _datasource.toggleFavorite(id));

  @override
  Future<ApiResult<void>> delete(int id) =>
      _wrap(() => _datasource.delete(id));

  @override
  Future<ApiResult<void>> clearAll() => _wrap(() => _datasource.clearAll());

  Future<ApiResult<T>> _wrap<T>(Future<T> Function() action) async {
    try {
      final result = await action();
      return Success(result);
    } on CacheException catch (e) {
      return ApiError(CacheFailure(e.message));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }
}
