import 'conversation_turn.dart';

/// What came of one recorded turn. [secondsRemaining] is the conversation
/// time left afterwards, when the server said.
sealed class TurnResult {
  const TurnResult({this.secondsRemaining});

  final int? secondsRemaining;
}

class TurnTranslated extends TurnResult {
  const TurnTranslated(this.turn, {super.secondsRemaining});

  final ConversationTurn turn;
}

/// Silence, noise, or too short to hold speech. Not charged.
class TurnNoSpeech extends TurnResult {
  const TurnNoSpeech({super.secondsRemaining});
}

/// Speech in neither of the two languages. Not charged.
class TurnUnsupportedLanguage extends TurnResult {
  const TurnUnsupportedLanguage({super.secondsRemaining});
}
