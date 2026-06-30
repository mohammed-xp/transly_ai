import 'package:equatable/equatable.dart';
import '../../../../core/domain/entities/language.dart';

final class ScanResult extends Equatable {
  const ScanResult({
    required this.recognizedText,
    required this.translatedText,
    required this.pair,
    required this.boundingBoxes,
  });

  final String recognizedText;
  final String translatedText;
  final LanguagePair pair;
  final List<TextBlock> boundingBoxes;

  @override
  List<Object?> get props => [recognizedText, translatedText, pair];
}

final class TextBlock extends Equatable {
  const TextBlock({
    required this.text,
    required this.translatedText,
  });

  final String text;
  final String translatedText;

  @override
  List<Object?> get props => [text, translatedText];
}
