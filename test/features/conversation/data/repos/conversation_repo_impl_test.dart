import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/domain/entities/language_entity.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/conversation/data/datasources/conversation_remote_data_source.dart';
import 'package:transly_ai/features/conversation/data/models/conversation_turn_response_model.dart';
import 'package:transly_ai/features/conversation/data/repos/conversation_repo_impl.dart';
import 'package:transly_ai/features/conversation/domain/entities/turn_result.dart';

import '../../../../helpers/conversation_cubit_factory.dart';

class _FakeRemote implements ConversationRemoteDataSource {
  /// Thrown one by one before answering.
  final List<Object> errors = [];
  final List<List<HistoryEntry>> histories = [];
  int calls = 0;

  @override
  Future<TurnReply> sendTurn({
    required String audioPath,
    required String languageA,
    required String languageB,
    required List<HistoryEntry> history,
  }) async {
    calls++;
    histories.add(history);
    if (errors.isNotEmpty) throw errors.removeAt(0);
    return (
      turn: ConversationTurnResponseModel(
        status: ConversationTurnStatus.noSpeech,
        sourceLanguage: null,
        targetLanguage: null,
        transcript: null,
        translation: null,
        createdAt: DateTime.utc(2026, 10, 28),
      ),
      secondsRemaining: 300,
    );
  }
}

DioException _status(int code) => DioException(
  requestOptions: RequestOptions(),
  type: DioExceptionType.badResponse,
  response: Response(requestOptions: RequestOptions(), statusCode: code),
);

void main() {
  late _FakeRemote remote;
  late ConversationRepoImpl repo;

  setUp(() {
    remote = _FakeRemote();
    repo = ConversationRepoImpl(remote);
  });

  Future<ApiResult<TurnResult>> send() => repo.sendTurn(
    audio: testRecording,
    languageA: LanguageEntity.arabic,
    languageB: LanguageEntity.english,
    history: [testTurn()],
  );

  test('returns the turn with the seconds left', () async {
    final result = await send();

    expect(result, isA<ApiSuccess<TurnResult>>());
    final turn = (result as ApiSuccess<TurnResult>).data;
    expect(turn, isA<TurnNoSpeech>());
    expect(turn.secondsRemaining, 300);
  });

  test(
    'sends the earlier turns as their language and original words',
    () async {
      await send();

      expect(remote.histories.single, [
        (language: 'en', text: testTurn().text),
      ]);
    },
  );

  for (final code in [502, 504]) {
    test('tries once more after a $code', () async {
      remote.errors.add(_status(code));

      final result = await send();

      expect(remote.calls, 2);
      expect(result, isA<ApiSuccess<TurnResult>>());
    });
  }

  test('gives up after a second 502', () async {
    remote.errors.addAll([_status(502), _status(502)]);

    final result = await send();

    expect(remote.calls, 2);
    expect((result as ApiFailure<TurnResult>).failure, isA<ServerFailure>());
  });

  test('does not retry a 500', () async {
    remote.errors.add(_status(500));

    await send();

    expect(remote.calls, 1);
  });

  test('maps a 429 to too many requests', () async {
    remote.errors.add(_status(429));

    final result = await send();

    expect(
      (result as ApiFailure<TurnResult>).failure,
      isA<TooManyRequestsFailure>(),
    );
  });

  test('maps a malformed ok turn to a format failure', () async {
    remote.errors.add(const FormatException('bad'));

    final result = await send();

    expect((result as ApiFailure<TurnResult>).failure, isA<FormatFailure>());
  });
}
