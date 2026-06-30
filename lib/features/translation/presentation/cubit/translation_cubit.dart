import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/domain/entities/language.dart';
import '../../../../core/domain/entities/translation_tone.dart';
import '../../../../core/result/api_result.dart';
import '../../domain/entities/translation.dart';
import '../../domain/usecases/translate_text_usecase.dart';
import 'translation_state.dart';

final class TranslationCubit extends Cubit<TranslationState> {
  TranslationCubit(this._translateText)
      : super(const TranslationIdle());

  final TranslateTextUseCase _translateText;

  LanguagePair get _currentPair => switch (state) {
        TranslationIdle(:final pair) => pair,
        TranslationInProgress(:final pair) => pair,
        TranslationError(:final pair) => pair,
        TranslationSuccess(:final translation) => translation.pair,
      };

  TranslationTone get _currentTone => switch (state) {
        TranslationIdle(:final tone) => tone,
        TranslationInProgress(:final tone) => tone,
        TranslationError(:final tone) => tone,
        TranslationSuccess(:final tone) => tone,
      };

  Future<void> translate(String text) async {
    if (text.trim().isEmpty) return;

    final pair = _currentPair;
    final tone = _currentTone;

    emit(TranslationInProgress(pair: pair, tone: tone));

    final result = await _translateText(
      TranslationRequest(text: text, pair: pair, tone: tone),
    );

    result.when(
      success: (translation) => emit(TranslationSuccess(translation: translation, tone: tone)),
      error: (failure) => emit(TranslationError(failure: failure, pair: pair, tone: tone)),
    );
  }

  void swapLanguages() {
    final pair = _currentPair.swapped;
    final tone = _currentTone;
    emit(TranslationIdle(pair: pair, tone: tone));
  }

  void setTone(TranslationTone tone) {
    emit(TranslationIdle(pair: _currentPair, tone: tone));
  }

  void setLanguagePair(LanguagePair pair) {
    emit(TranslationIdle(pair: pair, tone: _currentTone));
  }

  void reset() => emit(const TranslationIdle());
}
