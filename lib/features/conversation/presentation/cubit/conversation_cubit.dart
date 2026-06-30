import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/domain/entities/language.dart';
import '../../domain/entities/conversation_message.dart';
import 'conversation_state.dart';

final class ConversationCubit extends Cubit<ConversationState> {
  ConversationCubit() : super(const ConversationIdle());

  LanguagePair get _pair => switch (state) {
        ConversationIdle(:final pair) => pair,
        ConversationListening(:final pair) => pair,
        ConversationError() => LanguagePair.enToAr,
      };

  List<ConversationMessage> get _messages => switch (state) {
        ConversationIdle(:final messages) => messages,
        ConversationListening(:final messages) => messages,
        ConversationError() => const [],
      };

  void startListening(MessageSide side) {
    emit(ConversationListening(
      messages: _messages,
      pair: _pair,
      listeningFor: side,
    ));
  }

  void stopListening() {
    emit(ConversationIdle(messages: _messages, pair: _pair));
  }

  void addMessage(ConversationMessage message) {
    final updated = [..._messages, message];
    emit(ConversationIdle(messages: updated, pair: _pair));
  }

  void clear() => emit(ConversationIdle(pair: _pair));

  void setLanguagePair(LanguagePair pair) =>
      emit(ConversationIdle(messages: _messages, pair: pair));
}
