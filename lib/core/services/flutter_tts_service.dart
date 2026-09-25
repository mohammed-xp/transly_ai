import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'tts_service.dart';

class FlutterTtsService implements TtsService {
  FlutterTtsService(this._tts);

  final FlutterTts _tts;

  static const Map<String, String> _regionTags = {'en': 'en-US', 'ar': 'ar-SA'};

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
