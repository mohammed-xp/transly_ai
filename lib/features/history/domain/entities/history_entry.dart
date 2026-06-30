import 'package:equatable/equatable.dart';
import '../../../../core/domain/entities/language.dart';
import '../../../../core/domain/entities/translation_tone.dart';

final class HistoryEntry extends Equatable {
  const HistoryEntry({
    required this.id,
    required this.sourceText,
    required this.translatedText,
    required this.pair,
    required this.tone,
    required this.createdAt,
    this.isFavorite = false,
  });

  final int id;
  final String sourceText;
  final String translatedText;
  final LanguagePair pair;
  final TranslationTone tone;
  final DateTime createdAt;
  final bool isFavorite;

  HistoryEntry copyWith({bool? isFavorite}) => HistoryEntry(
        id: id,
        sourceText: sourceText,
        translatedText: translatedText,
        pair: pair,
        tone: tone,
        createdAt: createdAt,
        isFavorite: isFavorite ?? this.isFavorite,
      );

  @override
  List<Object?> get props => [id];
}
