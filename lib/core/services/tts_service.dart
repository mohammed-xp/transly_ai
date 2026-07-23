import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Thin abstraction over [FlutterTts] so callers can be unit-tested without
/// hitting platform channels. Lives in `core/services/` alongside other
/// device-capability wrappers; the conversation feature (voice mode) will
/// reuse it. TTS is a pure device capability with no business rules, so no
/// domain/repository layer is introduced for it (CLAUDE.md §A-4, smallest
/// change).
abstract class TtsService {
  /// Speaks [text] in [languageCode] ('en'/'ar'). No-op on blank text or when
  /// no matching voice is available on the device.
  Future<void> speak({required String text, required String languageCode});

  /// Stops any speech in progress.
  Future<void> stop();
}

class FlutterTtsService implements TtsService {
  FlutterTtsService(this._tts);

  final FlutterTts _tts;

  /// Region-qualified BCP-47 tags preferred over the bare domain code, since
  /// iOS voice lookup is region-qualified.
  static const Map<String, String> _regionTags = {'en': 'en-US', 'ar': 'ar-SA'};

  /// Caches only *successful* tag resolutions, so a repeated tap skips the
  /// probe round-trip. Failures are deliberately not cached: the user may
  /// install the missing voice from system settings, or the probe may have
  /// failed transiently — either way the next tap re-checks.
  final Map<String, String> _resolvedTags = {};

  @override
  Future<void> speak({
    required String text,
    required String languageCode,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final tag = await _resolveTag(languageCode);
    if (tag == null) return;

    try {
      await _tts.setLanguage(tag);
      await _tts.speak(trimmed);
    } on PlatformException catch (_) {
      // Non-critical device interaction — a speech failure shouldn't surface
      // as an app error (same spirit as the Copy button's Clipboard call).
      // Narrow on purpose: programming errors must still surface.
    } on MissingPluginException catch (_) {
      // No TTS engine wired up on this platform.
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } on PlatformException catch (_) {
      // See speak() — swallow device-level failures only.
    } on MissingPluginException catch (_) {
      // No TTS engine wired up on this platform.
    }
  }

  /// Picks the best usable tag for [languageCode], or null when the device
  /// can't speak it. Prefers the region-qualified tag, then the bare code.
  Future<String?> _resolveTag(String languageCode) async {
    final cached = _resolvedTags[languageCode];
    if (cached != null) return cached;

    try {
      final regionTag = _regionTags[languageCode];
      if (regionTag != null && await _isUsable(regionTag)) {
        return _resolvedTags[languageCode] = regionTag;
      }
      if (await _isUsable(languageCode)) {
        return _resolvedTags[languageCode] = languageCode;
      }
    } on PlatformException catch (_) {
      // Probe failed — leave unresolved and uncached so a later tap retries.
    } on MissingPluginException catch (_) {
      // Ditto.
    }
    return null;
  }

  /// Whether [tag] can actually produce audio.
  ///
  /// Prefers `isLanguageInstalled`, which verifies the voice data is actually
  /// downloaded — `isLanguageAvailable` also returns true for languages the
  /// engine merely knows about, which would leave us speaking into silence.
  /// `isLanguageInstalled` is Android-only, so when it isn't implemented we
  /// fall back to the portable check rather than treating it as unsupported.
  Future<bool> _isUsable(String tag) async {
    try {
      final installed = await _tts.isLanguageInstalled(tag);
      if (installed is bool) return installed;
    } on MissingPluginException catch (_) {
      // iOS/macOS don't implement it — fall through to the portable check.
    }
    return await _tts.isLanguageAvailable(tag) == true;
  }
}
