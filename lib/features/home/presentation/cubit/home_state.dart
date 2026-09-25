import '../../../../core/domain/entities/language_entity.dart';

class HomeState {
  const HomeState({required this.from, required this.to});

  factory HomeState.initial() => const HomeState(
    from: LanguageEntity.defaultSource,
    to: LanguageEntity.defaultTarget,
  );

  final LanguageEntity from;
  final LanguageEntity to;

  HomeState copyWith({LanguageEntity? from, LanguageEntity? to}) {
    return HomeState(from: from ?? this.from, to: to ?? this.to);
  }
}
