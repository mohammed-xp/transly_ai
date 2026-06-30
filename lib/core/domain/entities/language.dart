import 'package:equatable/equatable.dart';

final class Language extends Equatable {
  const Language({
    required this.code,
    required this.name,
    required this.nativeName,
    this.isRtl = false,
    this.isOfflineAvailable = false,
  });

  final String code;
  final String name;
  final String nativeName;
  final bool isRtl;
  final bool isOfflineAvailable;

  @override
  List<Object?> get props => [code];

  static const Language english = Language(
    code: 'en',
    name: 'English',
    nativeName: 'English',
  );

  static const Language arabic = Language(
    code: 'ar',
    name: 'Arabic',
    nativeName: 'العربية',
    isRtl: true,
  );

  static const Language german = Language(
    code: 'de',
    name: 'German',
    nativeName: 'Deutsch',
  );

  static const Language spanish = Language(
    code: 'es',
    name: 'Spanish',
    nativeName: 'Español',
  );

  static const Language french = Language(
    code: 'fr',
    name: 'French',
    nativeName: 'Français',
  );

  static const Language japanese = Language(
    code: 'ja',
    name: 'Japanese',
    nativeName: '日本語',
  );

  static const List<Language> wellKnown = [
    english,
    arabic,
    german,
    spanish,
    french,
    japanese,
  ];
}

final class LanguagePair extends Equatable {
  const LanguagePair({required this.source, required this.target});

  final Language source;
  final Language target;

  LanguagePair get swapped => LanguagePair(source: target, target: source);

  static const LanguagePair enToAr = LanguagePair(
    source: Language.english,
    target: Language.arabic,
  );

  @override
  List<Object?> get props => [source, target];
}
