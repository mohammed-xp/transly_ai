import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/services/flutter_tts_service.dart';

/// `isLanguageInstalled` needs a downloaded voice with exactly that locale,
/// like the Android plugin; `isLanguageAvailable` matches the language, like
/// both engines.
class _FakeFlutterTts implements FlutterTts {
  final List<String> voiceLocales = [];

  /// Listed by the engine but not downloaded.
  final Set<String> notInstalled = {};

  /// Replaces the voices built from [voiceLocales], as the channel sends them.
  Object? voicesOverride;
  bool overridesVoices = false;

  /// Holds `getVoices` until completed.
  Completer<void>? voicesGate;

  /// iOS doesn't implement `isLanguageInstalled`.
  bool implementsInstalledCheck = true;
  PlatformException? probeError;
  PlatformException? speakError;

  final Map<String, int> installChecks = {};
  final List<String> languages = [];
  final List<String> spoken = [];
  int voiceQueries = 0;

  @override
  Future<dynamic> awaitSpeakCompletion(bool awaitCompletion) async => 1;

  @override
  Future<dynamic> isLanguageInstalled(String language) async {
    if (!implementsInstalledCheck) throw MissingPluginException();
    final error = probeError;
    if (error != null) throw error;
    installChecks.update(language, (count) => count + 1, ifAbsent: () => 1);
    return voiceLocales.contains(language) && !notInstalled.contains(language);
  }

  @override
  Future<dynamic> isLanguageAvailable(String language) async =>
      voiceLocales.any((locale) => locale.startsWith(language));

  @override
  Future<dynamic> get getVoices async {
    voiceQueries++;
    await voicesGate?.future;
    if (overridesVoices) return voicesOverride;
    return <Object?>[
      for (final locale in voiceLocales)
        <Object?, Object?>{'name': '$locale-voice', 'locale': locale},
    ];
  }

  @override
  Future<dynamic> setLanguage(String language) async {
    languages.add(language);
    return 1;
  }

  @override
  Future<dynamic> speak(String text, {bool focus = false}) async {
    final error = speakError;
    if (error != null) throw error;
    spoken.add(text);
    return 1;
  }

  @override
  Future<dynamic> stop() async => 1;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late _FakeFlutterTts tts;
  late String? deviceCountry;
  late FlutterTtsService service;

  setUp(() {
    tts = _FakeFlutterTts();
    deviceCountry = null;
    service = FlutterTtsService(tts, deviceCountry: () => deviceCountry);
  });

  Failure failureOf(ApiResult<void> result) =>
      (result as ApiFailure<void>).failure;

  group('finding the voice', () {
    test('speaks Hindi with the regional voice the device has', () async {
      tts.voiceLocales.add('hi-IN');

      final result = await service.speak(text: 'नमस्ते', languageCode: 'hi');

      expect(result, isA<ApiSuccess<void>>());
      expect(tts.languages.single, 'hi-IN');
      expect(tts.spoken.single, 'नमस्ते');
    });

    test('keeps US English when it is installed', () async {
      tts.voiceLocales.addAll(['en-GB', 'en-US']);

      await service.speak(text: 'hello', languageCode: 'en');

      expect(tts.languages.single, 'en-US');
    });

    test('prefers the voice of the device region', () async {
      deviceCountry = 'US';
      tts.voiceLocales.addAll(['es-ES', 'es-US']);

      await service.speak(text: 'hola', languageCode: 'es');

      expect(tts.languages.single, 'es-US');
    });

    test('then prefers the language home region', () async {
      deviceCountry = 'EG';
      tts.voiceLocales.addAll(['fr-CA', 'fr-FR']);

      await service.speak(text: 'bonjour', languageCode: 'fr');

      expect(tts.languages.single, 'fr-FR');
    });

    test('then takes the voices in name order', () async {
      tts.voiceLocales.addAll(['zh-TW', 'zh-CN']);

      await service.speak(text: '你好', languageCode: 'zh');

      expect(tts.languages.single, 'zh-CN');
    });

    test('finds Tagalog under its Filipino voice', () async {
      tts.voiceLocales.add('fil-PH');

      await service.speak(text: 'kumusta', languageCode: 'tl');

      expect(tts.languages.single, 'fil-PH');
    });

    test('finds Norwegian under its Bokmål voice', () async {
      tts.voiceLocales.add('nb-NO');

      await service.speak(text: 'hei', languageCode: 'no');

      expect(tts.languages.single, 'nb-NO');
    });

    test('ignores a language whose code merely starts the same', () async {
      tts.voiceLocales.add('fil-PH');

      final result = await service.speak(text: 'hei', languageCode: 'fi');

      expect(failureOf(result), isA<VoiceUnavailableFailure>());
    });

    test('checks a locale shared by several voices only once', () async {
      tts.voicesOverride = <Object?>[
        <Object?, Object?>{'name': 'ja-1', 'locale': 'ja-JP'},
        <Object?, Object?>{'name': 'ja-2', 'locale': 'ja-JP'},
      ];
      tts.overridesVoices = true;

      await service.speak(text: 'こんにちは', languageCode: 'ja');

      expect(tts.installChecks['ja-JP'], 1);
    });

    test('does not check the region tag twice', () async {
      tts
        ..voiceLocales.add('en-US')
        ..notInstalled.add('en-US');

      await service.speak(text: 'hello', languageCode: 'en');

      expect(tts.installChecks['en-US'], 1);
    });

    test('skips voices that are not maps or have no locale', () async {
      tts.voicesOverride = <Object?>[
        'ja-JP',
        <Object?, Object?>{'name': 'nameless'},
        <Object?, Object?>{'name': 'ja', 'locale': 'ja-JP'},
      ];
      tts.overridesVoices = true;
      tts.voiceLocales.add('ja-JP');

      await service.speak(text: 'こんにちは', languageCode: 'ja');

      expect(tts.languages.single, 'ja-JP');
    });

    test('looks up the voice only once per language', () async {
      tts.voiceLocales.add('ja-JP');

      await service.speak(text: 'こんにちは', languageCode: 'ja');
      await service.speak(text: 'ありがとう', languageCode: 'ja');

      expect(tts.voiceQueries, 1);
    });

    test(
      'uses the availability check where there is no install check',
      () async {
        tts
          ..implementsInstalledCheck = false
          ..voiceLocales.add('hi-IN');

        await service.speak(text: 'नमस्ते', languageCode: 'hi');

        expect(tts.languages.single, 'hi');
      },
    );
  });

  group('no voice', () {
    test('fails without speaking when the language has no voice', () async {
      tts.voiceLocales.add('en-US');

      final result = await service.speak(text: 'こんにちは', languageCode: 'ja');

      expect(failureOf(result), isA<VoiceUnavailableFailure>());
      expect(tts.spoken, isEmpty);
    });

    test('fails when the voice is listed but not downloaded', () async {
      tts.voiceLocales.add('ja-JP');
      tts.notInstalled.add('ja-JP');

      final result = await service.speak(text: 'こんにちは', languageCode: 'ja');

      expect(failureOf(result), isA<VoiceUnavailableFailure>());
    });

    test('fails when the engine lists no voices', () async {
      tts.overridesVoices = true;

      final result = await service.speak(text: 'こんにちは', languageCode: 'ja');

      expect(failureOf(result), isA<VoiceUnavailableFailure>());
    });

    test('speaks once the missing voice is installed', () async {
      await service.speak(text: 'こんにちは', languageCode: 'ja');
      tts.voiceLocales.add('ja-JP');

      final result = await service.speak(text: 'こんにちは', languageCode: 'ja');

      expect(result, isA<ApiSuccess<void>>());
      expect(tts.languages.single, 'ja-JP');
    });
  });

  group('engine errors', () {
    test('a failed lookup is an unknown failure', () async {
      tts.probeError = PlatformException(code: 'tts');

      final result = await service.speak(text: 'hello', languageCode: 'en');

      expect(failureOf(result), isA<UnknownFailure>());
    });

    test('a failed lookup is retried on the next call', () async {
      tts
        ..voiceLocales.add('en-US')
        ..probeError = PlatformException(code: 'tts');
      await service.speak(text: 'hello', languageCode: 'en');
      tts.probeError = null;

      final result = await service.speak(text: 'hello', languageCode: 'en');

      expect(result, isA<ApiSuccess<void>>());
    });

    test('an error while speaking still succeeds', () async {
      tts
        ..voiceLocales.add('en-US')
        ..speakError = PlatformException(code: 'tts');

      final result = await service.speak(text: 'hello', languageCode: 'en');

      expect(result, isA<ApiSuccess<void>>());
    });
  });

  test('does not speak when stopped while looking up the voice', () async {
    tts
      ..voiceLocales.add('ja-JP')
      ..voicesGate = Completer<void>();
    final speaking = service.speak(text: 'こんにちは', languageCode: 'ja');
    await Future<void>.delayed(Duration.zero);

    await service.stop();
    tts.voicesGate!.complete();
    await speaking;

    expect(tts.spoken, isEmpty);
  });

  test('does nothing for blank text', () async {
    final result = await service.speak(text: '   ', languageCode: 'en');

    expect(result, isA<ApiSuccess<void>>());
    expect(tts.spoken, isEmpty);
  });
}
