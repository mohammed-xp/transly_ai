import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:transly_ai/core/services/flutter_tts_service.dart';

/// Overrides every method [FlutterTtsService] calls — none of them invoke
/// `super`, so the base class's private platform channel is never touched.
/// [TestWidgetsFlutterBinding.ensureInitialized] (below) satisfies the
/// `FlutterTts()` constructor, which registers a (never-triggered) method
/// call handler on that channel.
///
/// If [FlutterTtsService] ever calls a method not overridden here, the call
/// falls through to the real channel and silently returns null — so keep this
/// fake in step with the service.
class _FakeFlutterTts extends FlutterTts {
  final List<String> calls = [];

  /// Languages the engine reports as fully installed (voice data downloaded).
  Set<String> installedLanguages = {};

  /// Languages the engine merely knows about — may still produce no audio.
  Set<String> availableLanguages = {};

  /// When true, `isLanguageInstalled` behaves like iOS (not implemented).
  bool installedCheckUnsupported = false;

  Object? throwOnSpeak;
  Object? throwOnSetLanguage;
  Object? throwOnProbe;

  @override
  Future<dynamic> setLanguage(String language) async {
    calls.add('setLanguage:$language');
    if (throwOnSetLanguage != null) throw throwOnSetLanguage!;
    return 1;
  }

  @override
  Future<dynamic> isLanguageInstalled(String language) async {
    calls.add('isLanguageInstalled:$language');
    if (installedCheckUnsupported) {
      throw MissingPluginException('not implemented on this platform');
    }
    if (throwOnProbe != null) throw throwOnProbe!;
    return installedLanguages.contains(language);
  }

  @override
  Future<dynamic> isLanguageAvailable(String language) async {
    calls.add('isLanguageAvailable:$language');
    if (throwOnProbe != null) throw throwOnProbe!;
    return availableLanguages.contains(language);
  }

  @override
  Future<dynamic> speak(String text, {bool focus = false}) async {
    calls.add('speak:$text');
    if (throwOnSpeak != null) throw throwOnSpeak!;
    return 1;
  }

  @override
  Future<dynamic> stop() async {
    calls.add('stop');
    return 1;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlutterTtsService.speak — tag resolution', () {
    test(
      'prefers the region-qualified tag when its voice is installed',
      () async {
        final tts = _FakeFlutterTts()..installedLanguages = {'ar-SA'};
        final service = FlutterTtsService(tts);

        await service.speak(text: 'مرحبا', languageCode: 'ar');

        expect(tts.calls, [
          'isLanguageInstalled:ar-SA',
          'setLanguage:ar-SA',
          'speak:مرحبا',
        ]);
      },
    );

    test('falls back to the bare code when only it is installed', () async {
      final tts = _FakeFlutterTts()..installedLanguages = {'ar'};
      final service = FlutterTtsService(tts);

      await service.speak(text: 'مرحبا', languageCode: 'ar');

      expect(tts.calls, [
        'isLanguageInstalled:ar-SA',
        'isLanguageInstalled:ar',
        'setLanguage:ar',
        'speak:مرحبا',
      ]);
    });

    test('resolves English to its region tag', () async {
      final tts = _FakeFlutterTts()..installedLanguages = {'en-US'};
      final service = FlutterTtsService(tts);

      await service.speak(text: 'hello', languageCode: 'en');

      expect(tts.calls, contains('setLanguage:en-US'));
    });

    test(
      'does not speak a language the engine knows but has not installed',
      () async {
        // The exact Android trap: isLanguageAvailable says yes, but the voice
        // data was never downloaded, so speaking would produce silence.
        final tts = _FakeFlutterTts()..availableLanguages = {'ar-SA', 'ar'};
        final service = FlutterTtsService(tts);

        await service.speak(text: 'مرحبا', languageCode: 'ar');

        expect(
          tts.calls.where(
            (c) => c.startsWith('speak') || c.startsWith('setLanguage'),
          ),
          isEmpty,
        );
      },
    );

    test('falls back to isLanguageAvailable where isLanguageInstalled is '
        'unimplemented (iOS)', () async {
      final tts = _FakeFlutterTts()
        ..installedCheckUnsupported = true
        ..availableLanguages = {'ar-SA'};
      final service = FlutterTtsService(tts);

      await service.speak(text: 'مرحبا', languageCode: 'ar');

      expect(tts.calls, [
        'isLanguageInstalled:ar-SA',
        'isLanguageAvailable:ar-SA',
        'setLanguage:ar-SA',
        'speak:مرحبا',
      ]);
    });

    test('is a silent no-op when the language is unusable', () async {
      final tts = _FakeFlutterTts(); // nothing installed or available
      final service = FlutterTtsService(tts);

      await service.speak(text: 'hello', languageCode: 'en');

      expect(
        tts.calls.where(
          (c) => c.startsWith('setLanguage') || c.startsWith('speak'),
        ),
        isEmpty,
      );
    });

    test('is a no-op for empty or whitespace-only text', () async {
      final tts = _FakeFlutterTts()..installedLanguages = {'en-US'};
      final service = FlutterTtsService(tts);

      await service.speak(text: '   ', languageCode: 'en');

      expect(tts.calls, isEmpty);
    });
  });

  group('FlutterTtsService.speak — resolution caching', () {
    test('caches a successful resolution — one probe per language', () async {
      final tts = _FakeFlutterTts()..installedLanguages = {'en-US'};
      final service = FlutterTtsService(tts);

      await service.speak(text: 'one', languageCode: 'en');
      await service.speak(text: 'two', languageCode: 'en');

      expect(tts.calls.where((c) => c.startsWith('isLanguage')).length, 1);
      expect(tts.calls.where((c) => c.startsWith('speak')).length, 2);
    });

    test('caches each language independently', () async {
      final tts = _FakeFlutterTts()..installedLanguages = {'en-US', 'ar-SA'};
      final service = FlutterTtsService(tts);

      await service.speak(text: 'hello', languageCode: 'en');
      await service.speak(text: 'مرحبا', languageCode: 'ar');

      expect(tts.calls.where((c) => c.startsWith('isLanguage')).length, 2);
    });

    test(
      'does NOT cache a failed resolution — a later install is picked up',
      () async {
        final tts = _FakeFlutterTts(); // Arabic voice not installed yet
        final service = FlutterTtsService(tts);

        await service.speak(text: 'مرحبا', languageCode: 'ar');
        expect(tts.calls.where((c) => c.startsWith('speak')), isEmpty);

        // User installs the Arabic voice from system settings, then taps again.
        tts.installedLanguages = {'ar-SA'};
        await service.speak(text: 'مرحبا', languageCode: 'ar');

        expect(tts.calls, contains('speak:مرحبا'));
      },
    );

    test('does NOT cache a transient probe failure', () async {
      final tts = _FakeFlutterTts()
        ..installedLanguages = {'en-US'}
        ..throwOnProbe = PlatformException(code: 'transient');
      final service = FlutterTtsService(tts);

      await service.speak(text: 'hello', languageCode: 'en');
      expect(tts.calls.where((c) => c.startsWith('speak')), isEmpty);

      tts.throwOnProbe = null; // engine recovers
      await service.speak(text: 'hello', languageCode: 'en');

      expect(tts.calls, contains('speak:hello'));
    });
  });

  group('FlutterTtsService — failure handling', () {
    test('a platform exception from speak does not propagate', () async {
      final tts = _FakeFlutterTts()
        ..installedLanguages = {'en-US'}
        ..throwOnSpeak = PlatformException(code: 'tts_error');
      final service = FlutterTtsService(tts);

      await expectLater(
        service.speak(text: 'hello', languageCode: 'en'),
        completes,
      );
    });

    test('a platform exception from setLanguage does not propagate', () async {
      final tts = _FakeFlutterTts()
        ..installedLanguages = {'en-US'}
        ..throwOnSetLanguage = PlatformException(code: 'tts_error');
      final service = FlutterTtsService(tts);

      await expectLater(
        service.speak(text: 'hello', languageCode: 'en'),
        completes,
      );
      expect(tts.calls, isNot(contains('speak:hello')));
    });

    test('a programming error is NOT swallowed', () async {
      final tts = _FakeFlutterTts()
        ..installedLanguages = {'en-US'}
        ..throwOnSpeak = StateError('bug in our own code');
      final service = FlutterTtsService(tts);

      await expectLater(
        service.speak(text: 'hello', languageCode: 'en'),
        throwsStateError,
      );
    });
  });

  group('FlutterTtsService.stop', () {
    test('delegates to the underlying engine', () async {
      final tts = _FakeFlutterTts();
      final service = FlutterTtsService(tts);

      await service.stop();

      expect(tts.calls, ['stop']);
    });
  });
}
