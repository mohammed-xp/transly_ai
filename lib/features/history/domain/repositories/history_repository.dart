import '../../../../core/result/api_result.dart';
import '../entities/history_entry.dart';

abstract interface class HistoryRepository {
  Future<ApiResult<List<HistoryEntry>>> getAll();
  Future<ApiResult<List<HistoryEntry>>> search(String query);
  Future<ApiResult<void>> save(HistoryEntry entry);
  Future<ApiResult<void>> toggleFavorite(int id);
  Future<ApiResult<void>> delete(int id);
  Future<ApiResult<void>> clearAll();
}
