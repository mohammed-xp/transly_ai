import 'dart:async';

import 'package:transly_ai/core/domain/entities/language_entity.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/translate/domain/entities/tone_catalog.dart';
import 'package:transly_ai/features/translate/domain/entities/translation_engine.dart';
import 'package:transly_ai/features/translate/domain/entities/translation_entity.dart';
import 'package:transly_ai/features/translate/domain/entities/translation_tone.dart';
import 'package:transly_ai/features/translate/domain/repos/translation_repo.dart';

const formalTone = TranslationTone(code: 'formal', name: 'Formal');
const casualTone = TranslationTone(code: 'casual', name: 'Casual');
const conciseTone = TranslationTone(code: 'concise', name: 'Concise');

const defaultToneCatalog = ToneCatalog(
  tones: [formalTone, casualTone, conciseTone],
  defaultCode: 'formal',
);

class FakeTranslationRepo implements TranslationRepo {
  FakeTranslationRepo({
    this.cachedTones = defaultToneCatalog,
    this.syncedTones,
    this.syncFailure,
    this.savedToneCode,
    this.engine = TranslationEngine.online,
    this.translateFailure,
  });

  ToneCatalog? cachedTones;

  /// What a sync returns; [cachedTones] when null.
  ToneCatalog? syncedTones;

  /// Fails every sync with it when set.
  Failure? syncFailure;

  String? savedToneCode;

  /// The engine every translation reports it came from.
  TranslationEngine engine;

  /// Fails every translation with it when set.
  Failure? translateFailure;
  final List<String> savedToneCodes = [];
  final List<String?> requestedTones = [];
  int syncCalls = 0;

  /// While set, each sync waits in [pendingSyncs] until the test completes it.
  bool holdSyncs = false;
  final List<Completer<ApiResult<ToneCatalog>>> pendingSyncs = [];
  final StreamController<bool> onlineAvailability = StreamController<bool>();

  @override
  Future<ApiResult<TranslationEntity>> translate({
    required String text,
    required LanguageEntity from,
    required LanguageEntity to,
    required String? tone,
  }) async {
    requestedTones.add(tone);
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
  ToneCatalog? getCachedTones() => cachedTones;

  @override
  Future<ApiResult<ToneCatalog>> syncTones() async {
    syncCalls++;
    if (holdSyncs) {
      final pending = Completer<ApiResult<ToneCatalog>>();
      pendingSyncs.add(pending);
      return pending.future;
    }
    final failure = syncFailure;
    if (failure != null) return ApiResult.failure(failure);
    final tones = syncedTones ?? cachedTones;
    if (tones == null) return const ApiResult.failure(UnknownFailure());
    return ApiResult.success(tones);
  }

  @override
  String? getSavedToneCode() => savedToneCode;

  @override
  Future<ApiResult<void>> saveToneCode(String code) async {
    savedToneCodes.add(code);
    savedToneCode = code;
    return const ApiResult.success(null);
  }
}
