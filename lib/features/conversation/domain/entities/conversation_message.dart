import 'package:equatable/equatable.dart';
import '../../../../core/domain/entities/language.dart';

enum MessageSide { local, remote }

final class ConversationMessage extends Equatable {
  const ConversationMessage({
    required this.originalText,
    required this.translatedText,
    required this.language,
    required this.side,
    required this.timestamp,
  });

  final String originalText;
  final String translatedText;
  final Language language;
  final MessageSide side;
  final DateTime timestamp;

  @override
  List<Object?> get props => [originalText, language, side, timestamp];
}
