import 'package:equatable/equatable.dart';
import '../../../../core/domain/entities/language.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/conversation_message.dart';

sealed class ConversationState extends Equatable {
  const ConversationState();
  @override
  List<Object?> get props => [];
}

final class ConversationIdle extends ConversationState {
  const ConversationIdle({
    this.messages = const [],
    this.pair = LanguagePair.enToAr,
  });

  final List<ConversationMessage> messages;
  final LanguagePair pair;

  @override
  List<Object?> get props => [messages, pair];
}

final class ConversationListening extends ConversationState {
  const ConversationListening({
    required this.messages,
    required this.pair,
    required this.listeningFor,
  });

  final List<ConversationMessage> messages;
  final LanguagePair pair;
  final MessageSide listeningFor;

  @override
  List<Object?> get props => [messages, pair, listeningFor];
}

final class ConversationError extends ConversationState {
  const ConversationError({required this.failure});
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
