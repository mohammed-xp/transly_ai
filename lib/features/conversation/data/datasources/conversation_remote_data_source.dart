import '../models/conversation_turn_response_model.dart';

/// An earlier turn sent back as context: its language and the original
/// words, not the translation.
typedef HistoryEntry = ({String language, String text});

/// The turn, and the conversation seconds left from the
/// `X-Audio-Seconds-Remaining` header.
typedef TurnReply = ({
  ConversationTurnResponseModel turn,
  int? secondsRemaining,
});

abstract class ConversationRemoteDataSource {
  Future<TurnReply> sendTurn({
    required String audioPath,
    required String languageA,
    required String languageB,
    required List<HistoryEntry> history,
  });
}
