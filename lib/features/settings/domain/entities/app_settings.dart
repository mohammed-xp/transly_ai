import 'package:equatable/equatable.dart';
import '../../../../core/domain/entities/language.dart';
import '../../../../core/domain/entities/translation_tone.dart';

final class AppSettings extends Equatable {
  const AppSettings({
    this.defaultPair = LanguagePair.enToAr,
    this.defaultTone = TranslationTone.formal,
    this.autoPlayAudio = false,
    this.useDarkMode = false,
    this.installedOfflinePacks = const [],
  });

  final LanguagePair defaultPair;
  final TranslationTone defaultTone;
  final bool autoPlayAudio;
  final bool useDarkMode;
  final List<String> installedOfflinePacks;

  AppSettings copyWith({
    LanguagePair? defaultPair,
    TranslationTone? defaultTone,
    bool? autoPlayAudio,
    bool? useDarkMode,
    List<String>? installedOfflinePacks,
  }) =>
      AppSettings(
        defaultPair: defaultPair ?? this.defaultPair,
        defaultTone: defaultTone ?? this.defaultTone,
        autoPlayAudio: autoPlayAudio ?? this.autoPlayAudio,
        useDarkMode: useDarkMode ?? this.useDarkMode,
        installedOfflinePacks: installedOfflinePacks ?? this.installedOfflinePacks,
      );

  @override
  List<Object?> get props => [
        defaultPair,
        defaultTone,
        autoPlayAudio,
        useDarkMode,
        installedOfflinePacks,
      ];
}
