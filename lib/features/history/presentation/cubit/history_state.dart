import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/history_entry.dart';

sealed class HistoryState extends Equatable {
  const HistoryState();
  @override
  List<Object?> get props => [];
}

final class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

final class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

final class HistoryLoaded extends HistoryState {
  const HistoryLoaded({required this.entries, this.query = ''});

  final List<HistoryEntry> entries;
  final String query;

  @override
  List<Object?> get props => [entries, query];
}

final class HistoryError extends HistoryState {
  const HistoryError({required this.failure});
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
