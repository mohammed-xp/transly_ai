import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/domain/entities/user_entity.dart';

class HomeState {
  const HomeState({required this.from, required this.to, this.user});

  factory HomeState.initial({UserEntity? user}) => HomeState(
    from: LanguageEntity.defaultSource,
    to: LanguageEntity.defaultTarget,
    user: user,
  );

  final LanguageEntity from;
  final LanguageEntity to;

  /// Null when no user is cached — the header then shows a generic avatar.
  final UserEntity? user;

  HomeState copyWith({LanguageEntity? from, LanguageEntity? to}) {
    return HomeState(from: from ?? this.from, to: to ?? this.to, user: user);
  }
}
