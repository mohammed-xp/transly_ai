import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/domain/entities/language_entity.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/conversation/domain/entities/recorded_audio.dart';
import 'package:transly_ai/features/conversation/domain/entities/turn_result.dart';
import 'package:transly_ai/features/conversation/domain/usecases/send_conversation_turn_usecase.dart';

import '../../../../helpers/conversation_cubit_factory.dart';

void main() {
  late FakeConversationRepo repo;
  late SendConversationTurnUseCase sendTurn;

  setUp(() {
    repo = FakeConversationRepo();
    sendTurn = SendConversationTurnUseCase(repo);
  });

  test('sends the recording with both languages', () async {
    await sendTurn(
      audio: testRecording,
      languageA: LanguageEntity.english,
      languageB: LanguageEntity.arabic,
      previousTurns: const [],
    );

    expect(repo.sent.single.audio, testRecording);
    expect(repo.sent.single.languageA, LanguageEntity.english);
    expect(repo.sent.single.languageB, LanguageEntity.arabic);
  });

  test('sends only the latest earlier turns, oldest first', () async {
    final turns = [for (var i = 0; i < 6; i++) testTurn(text: 'turn $i')];

    await sendTurn(
      audio: testRecording,
      languageA: LanguageEntity.english,
      languageB: LanguageEntity.arabic,
      previousTurns: turns,
    );

    expect(repo.sent.single.history.map((turn) => turn.text), [
      'turn 2',
      'turn 3',
      'turn 4',
      'turn 5',
    ]);
  });

  test('a recording too short to hold speech is not sent', () async {
    final result = await sendTurn(
      audio: const RecordedAudio(
        path: 'turn.wav',
        duration: Duration(milliseconds: 300),
      ),
      languageA: LanguageEntity.english,
      languageB: LanguageEntity.arabic,
      previousTurns: const [],
    );

    expect(repo.sent, isEmpty);
    expect((result as ApiSuccess<TurnResult>).data, isA<TurnNoSpeech>());
  });
}
