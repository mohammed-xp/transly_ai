import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/result/api_result.dart';
import '../../domain/repositories/history_repository.dart';
import 'history_state.dart';

final class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit(this._repository) : super(const HistoryInitial());

  final HistoryRepository _repository;

  Future<void> load() async {
    emit(const HistoryLoading());
    final result = await _repository.getAll();
    result.when(
      success: (entries) => emit(HistoryLoaded(entries: entries)),
      error: (failure) => emit(HistoryError(failure: failure)),
    );
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      await load();
      return;
    }
    emit(const HistoryLoading());
    final result = await _repository.search(query);
    result.when(
      success: (entries) => emit(HistoryLoaded(entries: entries, query: query)),
      error: (failure) => emit(HistoryError(failure: failure)),
    );
  }

  Future<void> toggleFavorite(int id) async {
    await _repository.toggleFavorite(id);
    await load();
  }

  Future<void> delete(int id) async {
    await _repository.delete(id);
    await load();
  }
}
