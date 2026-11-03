import 'dart:async';

import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/result/api_result.dart';
import '../../../../core/services/analytics_event.dart';
import '../../../../core/services/analytics_service.dart';
import '../entities/conversation_failure.dart';
import '../entities/conversation_turn.dart';
import '../entities/recorded_audio.dart';
import '../entities/turn_result.dart';
import '../repos/conversation_repo.dart';

/// Translates one recorded turn, with the latest earlier turns as context.
class SendConversationTurnUseCase {
  const SendConversationTurnUseCase(this._repo, this._analytics);

  final ConversationRepo _repo;
  final AnalyticsService _analytics;

  /// The most earlier turns the server reads.
  static const int historyLimit = 4;

  /// A recording too short to hold speech isn't sent: the server would only
  /// answer that there was none.
  Future<ApiResult<TurnResult>> call({
    required RecordedAudio audio,
    required LanguageEntity languageA,
    required LanguageEntity languageB,
    required List<ConversationTurn> previousTurns,
  }) async {
    if (audio.duration < RecordedAudio.minDuration) {
      return const ApiResult.success(TurnNoSpeech());
    }
    final history = previousTurns.length > historyLimit
        ? previousTurns.sublist(previousTurns.length - historyLimit)
        : previousTurns;
    final result = await _repo.sendTurn(
      audio: audio,
      languageA: languageA,
      languageB: languageB,
      history: history,
    );
    switch (result) {
      case ApiSuccess(data: TurnTranslated()):
        unawaited(
          _analytics.logEvent(
            ConversationTurnEvent(
              languageA: languageA.code,
              languageB: languageB.code,
            ),
          ),
        );
      case ApiFailure(:final failure) when failure.isOutOfConversationTime:
        unawaited(
          _analytics.logEvent(
            const QuotaReachedEvent(QuotaFeature.conversation),
          ),
        );
      case ApiSuccess() || ApiFailure():
        break;
    }
    return result;
  }
}
