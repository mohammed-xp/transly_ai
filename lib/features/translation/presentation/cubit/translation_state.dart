import 'package:equatable/equatable.dart';
import '../../../../core/domain/entities/language.dart';
import '../../../../core/domain/entities/translation_tone.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/translation.dart';

sealed class TranslationState extends Equatable {
  const TranslationState();
  @override
  List<Object?> get props => [];
}

final class TranslationIdle extends TranslationState {
  const TranslationIdle({
    this.pair = LanguagePair.enToAr,
    this.tone = TranslationTone.formal,
  });

  final LanguagePair pair;
  final TranslationTone tone;

  @override
  List<Object?> get props => [pair, tone];
}

final class TranslationInProgress extends TranslationState {
  const TranslationInProgress({required this.pair, required this.tone});

  final LanguagePair pair;
  final TranslationTone tone;

  @override
  List<Object?> get props => [pair, tone];
}

final class TranslationSuccess extends TranslationState {
  const TranslationSuccess({
    required this.translation,
    required this.tone,
  });

  final Translation translation;
  final TranslationTone tone;

  @override
  List<Object?> get props => [translation, tone];
}

final class TranslationError extends TranslationState {
  const TranslationError({
    required this.failure,
    required this.pair,
    required this.tone,
  });

  final Failure failure;
  final LanguagePair pair;
  final TranslationTone tone;

  @override
  List<Object?> get props => [failure, pair, tone];
}
