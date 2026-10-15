import 'dart:async';

import 'package:transly_ai/core/domain/entities/language_entity.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/translate/domain/entities/translation_engine.dart';
import 'package:transly_ai/features/translate/domain/entities/translation_entity.dart';
import 'package:transly_ai/features/translate/domain/entities/translation_tone.dart';
import 'package:transly_ai/features/translate/domain/repos/translation_repo.dart';

class FakeTranslationRepo implements TranslationRepo {
  FakeTranslationRepo({
    this.savedTone = TranslationTone.formal,
    this.engine = TranslationEngine.online,
    this.translateFailure,
  });

  TranslationTone savedTone;

  /// The engine every translation reports it came from.
  TranslationEngine engine;

  /// Fails every translation with it when set.
  Failure? translateFailure;
  final List<TranslationTone> savedTones = [];
  final StreamController<bool> onlineAvailability = StreamController<bool>();

  @override
  Future<ApiResult<TranslationEntity>> translate({
    required String text,
    required LanguageEntity from,
    required LanguageEntity to,
    required String tone,
  }) async {
    final failure = translateFailure;
    if (failure != null) return ApiResult.failure(failure);
    return ApiResult.success(
      TranslationEntity(
        sourceText: text,
        translatedText: text,
        from: from,
        to: to,
        model: null,
        engine: engine,
      ),
    );
  }

  @override
  Stream<bool> watchOnlineAvailability() => onlineAvailability.stream;

  @override
  TranslationTone getSavedTone() => savedTone;

  @override
  Future<ApiResult<void>> saveTone(TranslationTone tone) async {
    savedTones.add(tone);
    savedTone = tone;
    return const ApiResult.success(null);
  }
}
