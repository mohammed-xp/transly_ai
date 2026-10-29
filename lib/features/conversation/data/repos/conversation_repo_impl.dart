import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/api_result.dart';
import '../../domain/entities/conversation_turn.dart';
import '../../domain/entities/recorded_audio.dart';
import '../../domain/entities/turn_result.dart';
import '../../domain/repos/conversation_repo.dart';
import '../datasources/conversation_remote_data_source.dart';

class ConversationRepoImpl implements ConversationRepo {
  ConversationRepoImpl(this._remote);

  final ConversationRemoteDataSource _remote;

  @override
  Future<ApiResult<TurnResult>> sendTurn({
    required RecordedAudio audio,
    required LanguageEntity languageA,
    required LanguageEntity languageB,
    required List<ConversationTurn> history,
  }) async {
    final entries = [
      for (final turn in history)
        (language: turn.language.code, text: turn.text),
    ];
    for (var attempt = 1; ; attempt++) {
      try {
        final reply = await _remote.sendTurn(
          audioPath: audio.path,
          languageA: languageA.code,
          languageB: languageB.code,
          history: entries,
        );
        return ApiResult.success(
          reply.turn.toResult(secondsRemaining: reply.secondsRemaining),
        );
      } catch (e) {
        final failure = ErrorMapper.map(e);
        if (attempt == 1 && _isWorthOneRetry(failure)) continue;
        return ApiResult.failure(failure);
      }
    }
  }

  /// A bad (502) or late (504) answer from the translation service often
  /// works the second time.
  static bool _isWorthOneRetry(Failure failure) =>
      failure is ServerFailure &&
      (failure.statusCode == 502 || failure.statusCode == 504);
}
