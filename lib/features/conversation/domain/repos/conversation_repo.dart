import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/result/api_result.dart';
import '../entities/conversation_turn.dart';
import '../entities/recorded_audio.dart';
import '../entities/turn_result.dart';

abstract class ConversationRepo {
  /// Translates the turn in [audio], spoken in [languageA] or [languageB].
  /// [history] gives earlier turns as context, oldest first.
  Future<ApiResult<TurnResult>> sendTurn({
    required RecordedAudio audio,
    required LanguageEntity languageA,
    required LanguageEntity languageB,
    required List<ConversationTurn> history,
  });
}
