import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../errors/failure.dart';
import '../result/api_result.dart';
import 'tts_service.dart';

class FlutterTtsService implements TtsService {
  FlutterTtsService(this._tts, {required String? Function() deviceCountry})
    : _deviceCountry = deviceCountry;

  final FlutterTts _tts;

  /// The device's region (`US`, `EG`), preferred among a language's voices.
  final String? Function() _deviceCountry;

  static const Map<String, String> _regionTags = {'en': 'en-US', 'ar': 'ar-SA'};

  /// ML Kit codes whose voices go by another code.
  static const Map<String, String> _voiceCodes = {
    'tl': 'fil',
    'no': 'nb',
    'iw': 'he',
    'jw': 'jv',
  };

  final Map<String, String> _resolvedTags = {};
  bool _awaitsCompletion = false;

  /// Bumped by [stop], so a voice lookup that finishes later doesn't start
  /// speaking anyway.
  int _stops = 0;

  @override
  Future<ApiResult<void>> speak({
    required String text,
    required String languageCode,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return const ApiResult.success(null);

    final stops = _stops;
    final String? tag;
    try {
      tag = await _resolveTag(languageCode);
    } on PlatformException catch (_) {
      // The engine couldn't be asked; nothing is cached, so a later tap
      // retries.
      return const ApiResult.failure(UnknownFailure());
    } on MissingPluginException catch (_) {
      // No TTS engine wired up on this platform.
      return const ApiResult.failure(VoiceUnavailableFailure());
    }
    if (tag == null) {
      return const ApiResult.failure(VoiceUnavailableFailure());
    }

    try {
      if (!_awaitsCompletion) {
        await _tts.awaitSpeakCompletion(true);
        _awaitsCompletion = true;
      }
      await _tts.setLanguage(tag);
      if (stops != _stops) return const ApiResult.success(null);
      await _tts.speak(trimmed);
    } on PlatformException catch (_) {
      // Non-critical device interaction — a speech failure shouldn't surface
      // as an app error (same spirit as the Copy button's Clipboard call).
      // Narrow on purpose: programming errors must still surface.
    } on MissingPluginException catch (_) {
      // No TTS engine wired up on this platform.
    }
    return const ApiResult.success(null);
  }

  @override
  Future<void> stop() async {
    _stops++;
    try {
      await _tts.stop();
    } on PlatformException catch (_) {
      // See speak() — swallow device-level failures only.
    } on MissingPluginException catch (_) {
      // No TTS engine wired up on this platform.
    }
  }

  /// Null when the device has no usable voice. Only a found voice is cached,
  /// so one installed later is picked up on the next tap.
  Future<String?> _resolveTag(String languageCode) async {
    final cached = _resolvedTags[languageCode];
    if (cached != null) return cached;

    final probed = <String>{};
    Future<bool> isNewAndUsable(String tag) async =>
        probed.add(tag.toLowerCase()) && await _isUsable(tag);

    final regionTag = _regionTags[languageCode];
    if (regionTag != null && await isNewAndUsable(regionTag)) {
      return _resolvedTags[languageCode] = regionTag;
    }
    if (await isNewAndUsable(languageCode)) {
      return _resolvedTags[languageCode] = languageCode;
    }
    // Android only accepts the exact locale of an installed voice, and
    // voices carry a region (`hi-IN`), so a bare `hi` never matches.
    for (final voiceTag in await _voiceTags(languageCode)) {
      if (await isNewAndUsable(voiceTag)) {
        return _resolvedTags[languageCode] = voiceTag;
      }
    }
    return null;
  }

  /// The device's voice locales for [languageCode], e.g. `hi-IN`, best first:
  /// the device's region, then the language's home region (`fr-FR`), then
  /// the rest by name. Android hands the voices over in no stable order.
  Future<List<String>> _voiceTags(String languageCode) async {
    final voices = await _tts.getVoices;
    if (voices is! List) return const [];
    final code = languageCode.toLowerCase();
    final voiceCode = _voiceCodes[code] ?? code;
    final tags = {
      for (final voice in voices)
        if (voice is Map)
          if (voice['locale'] case final String locale
              when locale.toLowerCase().startsWith('$voiceCode-'))
            locale,
    }.toList();

    final country = _deviceCountry()?.toLowerCase();
    int rank(String tag) => switch (tag.toLowerCase()) {
      final t when country != null && t == '$voiceCode-$country' => 0,
      final t when t == '$voiceCode-$voiceCode' => 1,
      _ => 2,
    };
    return tags..sort((a, b) {
      final byRank = rank(a).compareTo(rank(b));
      return byRank != 0 ? byRank : a.compareTo(b);
    });
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
