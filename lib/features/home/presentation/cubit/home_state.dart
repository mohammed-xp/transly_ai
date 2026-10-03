import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/domain/entities/user_entity.dart';

class HomeState {
  const HomeState({
    required this.from,
    required this.to,
    this.user,
    this.isPro = false,
  });

  factory HomeState.initial({UserEntity? user, bool isPro = false}) =>
      HomeState(
        from: LanguageEntity.defaultSource,
        to: LanguageEntity.defaultTarget,
        user: user,
        isPro: isPro,
      );

  final LanguageEntity from;
  final LanguageEntity to;

  /// Null when no user is cached — the header then shows a generic avatar.
  final UserEntity? user;

  /// From the last known plan until the server confirms the current one.
  final bool isPro;

  HomeState copyWith({LanguageEntity? from, LanguageEntity? to, bool? isPro}) {
    return HomeState(
      from: from ?? this.from,
      to: to ?? this.to,
      user: user,
      isPro: isPro ?? this.isPro,
    );
  }
}
