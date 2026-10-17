import 'translation_tone.dart';

class ToneCatalog {
  const ToneCatalog({required this.tones, required this.defaultCode});

  final List<TranslationTone> tones;
  final String defaultCode;

  /// The tone for [code] if it is still offered, else the default, else the
  /// first one. Null only when there are no tones at all.
  TranslationTone? resolve(String? code) {
    if (tones.isEmpty) return null;
    TranslationTone? find(String? code) =>
        tones.where((tone) => tone.code == code).firstOrNull;
    return find(code) ?? find(defaultCode) ?? tones.first;
  }
}
