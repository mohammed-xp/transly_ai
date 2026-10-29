import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/domain/entities/language_entity.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/conversation/domain/entities/recorded_audio.dart';
import 'package:transly_ai/features/conversation/domain/entities/turn_result.dart';
import 'package:transly_ai/features/conversation/presentation/cubit/conversation_cubit.dart';
import 'package:transly_ai/features/conversation/presentation/cubit/conversation_state.dart';
import 'package:transly_ai/features/profile/domain/entities/plan_usage_entity.dart';

import '../../../../helpers/conversation_cubit_factory.dart';
import '../../../../helpers/fake_plan_usage_repo.dart';

void main() {
  const french = LanguageEntity(
    code: 'fr',
    name: 'French',
    nativeName: 'Français',
    isRtl: false,
  );

  late FakeVoiceRecorderRepo recorder;
  late FakeConversationRepo conversation;
  late FakeTts tts;
  late FakeConnectivity connectivity;
  late FakePlanUsageRepo usage;
  late ConversationCubit cubit;

  setUp(() {
    recorder = FakeVoiceRecorderRepo();
    conversation = FakeConversationRepo();
    tts = FakeTts();
    connectivity = FakeConnectivity();
    usage = FakePlanUsageRepo(ApiResult.success(testFreeUsage));
    cubit = buildConversationCubit(
      recorder: recorder,
      conversation: conversation,
      tts: tts,
      connectivity: connectivity,
      usage: usage,
    );
  });

  tearDown(() => cubit.close());

  /// Lets the connection stream deliver its first answer.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  /// Records a turn and sends it.
  Future<void> speakOneTurn() async {
    await cubit.micTapped();
    await cubit.micTapped();
  }

  test('starts empty and idle on the default pair', () {
    expect(cubit.state.from, LanguageEntity.defaultSource);
    expect(cubit.state.to, LanguageEntity.defaultTarget);
    expect(cubit.state.isEmpty, isTrue);
    expect(cubit.state.status, isA<ConversationIdle>());
    expect(cubit.state.readAloud, isTrue);
  });

  group('connection', () {
    test('goes offline when the connection drops', () async {
      await settle();
      connectivity.emit(false);
      await settle();

      expect(cubit.state.isOffline, isTrue);
    });

    test('starts offline when there is no connection', () async {
      await cubit.close();
      cubit = buildConversationCubit(
        connectivity: FakeConnectivity(connected: false),
      );
      await settle();

      expect(cubit.state.isOffline, isTrue);
    });

    test(
      'throws away a turn being recorded when the connection drops',
      () async {
        await settle();
        await cubit.micTapped();

        connectivity.emit(false);
        await settle();

        expect(cubit.state.status, isA<ConversationIdle>());
        expect(recorder.cancels, 1);
      },
    );

    test('ignores the mic while offline', () async {
      await settle();
      connectivity.emit(false);
      await settle();

      await cubit.micTapped();

      expect(recorder.starts, 0);
    });
  });

  group('recording', () {
    test(
      'asks for the microphone and shows the denied state if refused',
      () async {
        recorder.permitted = false;

        await cubit.micTapped();

        expect(recorder.permissionRequests, 1);
        expect(cubit.state.status, isA<ConversationMicDenied>());
        expect(recorder.starts, 0);
      },
    );

    test('starts recording when the microphone is allowed', () async {
      await cubit.micTapped();

      expect(recorder.starts, 1);
      expect(cubit.state.status, isA<ConversationRecording>());
    });

    test('stops any speech before recording', () async {
      await cubit.micTapped();

      expect(tts.stops, 1);
    });

    test('tells the user when the recorder fails to start', () async {
      recorder.startResult = const ApiResult.failure(UnknownFailure());

      await cubit.micTapped();

      expect(cubit.state.status, isA<ConversationIdle>());
      expect(cubit.state.notice, isA<RecordingFailedNotice>());
    });

    test('stops by itself at the longest turn the server accepts', () {
      fakeAsync((async) {
        cubit.micTapped();
        async.flushMicrotasks();
        expect(cubit.state.status, isA<ConversationRecording>());

        async.elapse(RecordedAudio.maxDuration);
        async.flushMicrotasks();

        expect(recorder.stops, 1);
        expect(conversation.sent, hasLength(1));
      });
    });

    test('pausing throws away the turn being recorded', () async {
      await cubit.micTapped();

      await cubit.pause();

      expect(recorder.cancels, 1);
      expect(cubit.state.status, isA<ConversationIdle>());
      expect(conversation.sent, isEmpty);
    });
  });

  group('a sent turn', () {
    test('goes out with both languages', () async {
      await speakOneTurn();

      final sent = conversation.sent.single;
      expect(sent.audio, testRecording);
      expect(sent.languageA, LanguageEntity.english);
      expect(sent.languageB, LanguageEntity.arabic);
    });

    test('shows as translating until the reply comes', () async {
      conversation.gate = Completer<void>();
      await cubit.micTapped();

      unawaited(cubit.micTapped());
      await settle();

      expect(cubit.state.status, isA<ConversationTranslating>());
      conversation.gate!.complete();
    });

    test('adds the translated turn', () async {
      await speakOneTurn();

      expect(cubit.state.turns, hasLength(1));
      expect(cubit.state.status, isA<ConversationIdle>());
    });

    test('sends the earlier turns as context', () async {
      await speakOneTurn();
      await speakOneTurn();

      expect(conversation.sent.last.history, hasLength(1));
    });

    test('reads the translation aloud in its language', () async {
      await speakOneTurn();

      expect(tts.spoken.single, (testTurn().translation, 'ar'));
    });

    test('is not read aloud when read-aloud is off', () async {
      cubit.setReadAloud(false);

      await speakOneTurn();

      expect(tts.spoken, isEmpty);
    });

    test('deletes the recording once translated', () async {
      await speakOneTurn();

      expect(recorder.discarded, [testRecording]);
    });

    test('takes the time left from the reply', () async {
      conversation.result = ApiResult.success(
        TurnTranslated(testTurn(), secondsRemaining: 120),
      );

      await speakOneTurn();

      expect(cubit.state.secondsRemaining, 120);
    });

    test('with no speech in it tells the user and adds nothing', () async {
      conversation.result = const ApiResult.success(TurnNoSpeech());

      await speakOneTurn();

      expect(cubit.state.turns, isEmpty);
      expect(cubit.state.notice, isA<NoSpeechNotice>());
    });

    test('in another language tells the user and adds nothing', () async {
      conversation.result = const ApiResult.success(TurnUnsupportedLanguage());

      await speakOneTurn();

      expect(cubit.state.turns, isEmpty);
      expect(cubit.state.notice, isA<UnsupportedLanguageNotice>());
    });
  });

  group('a failed turn', () {
    test('can be sent again after a network failure', () async {
      conversation.result = const ApiResult.failure(NetworkFailure());

      await speakOneTurn();

      expect(cubit.state.notice, isA<TurnFailedNotice>());
      expect(cubit.state.canRetry, isTrue);
      expect(recorder.discarded, isEmpty);
    });

    test('retrying sends the same recording again', () async {
      conversation.result = const ApiResult.failure(NetworkFailure());
      await speakOneTurn();
      conversation.result = ApiResult.success(TurnTranslated(testTurn()));

      await cubit.retryLastTurn();

      expect(conversation.sent, hasLength(2));
      expect(conversation.sent.last.audio, testRecording);
      expect(cubit.state.turns, hasLength(1));
    });

    test('is not offered again when the request itself was wrong', () async {
      conversation.result = const ApiResult.failure(
        ClientFailure(statusCode: 400),
      );

      await speakOneTurn();

      expect(cubit.state.canRetry, isFalse);
      expect(recorder.discarded, [testRecording]);
    });

    test('a new recording drops the failed one', () async {
      conversation.result = const ApiResult.failure(NetworkFailure());
      await speakOneTurn();

      await cubit.micTapped();

      expect(recorder.discarded, [testRecording]);
      expect(cubit.state.canRetry, isFalse);
    });

    test('out of time tells the user and reads when it comes back', () async {
      conversation.result = const ApiResult.failure(
        TooManyRequestsFailure(statusCode: 429),
      );
      usage.result = ApiResult.success(
        PlanUsageEntity(
          plan: PlanUsageEntity.freePlan,
          charactersLimit: 1500,
          charactersUsed: 0,
          resetsAt: DateTime.utc(2026, 10, 29),
          audioSecondsLimit: 300,
          audioSecondsRemaining: 0,
        ),
      );

      await speakOneTurn();
      await settle();

      expect(cubit.state.notice, isA<OutOfTimeNotice>());
      expect(cubit.state.isOutOfTime, isTrue);
      expect(cubit.state.quotaResetsAt, DateTime.utc(2026, 10, 29));
    });
  });

  test('ignores the mic once the time is used up', () async {
    await cubit.close();
    cubit = buildConversationCubit(
      recorder: recorder,
      initialState: ConversationState.initial().copyWith(secondsRemaining: 0),
    );

    await cubit.micTapped();

    expect(recorder.starts, 0);
  });

  test('refreshQuota reads the conversation time left', () async {
    usage.result = ApiResult.success(
      PlanUsageEntity(
        plan: PlanUsageEntity.freePlan,
        charactersLimit: 1500,
        charactersUsed: 0,
        resetsAt: DateTime.utc(2026, 10, 29),
        audioSecondsRemaining: 258,
      ),
    );

    await cubit.refreshQuota();

    expect(cubit.state.secondsRemaining, 258);
  });

  group('languages', () {
    test('a new pair starts a new conversation', () async {
      await speakOneTurn();

      cubit.languagesChanged(from: french, to: LanguageEntity.english);

      expect(cubit.state.from, french);
      expect(cubit.state.turns, isEmpty);
    });

    test('a reply for the old pair is dropped', () async {
      conversation.gate = Completer<void>();
      await cubit.micTapped();
      final sending = cubit.micTapped();
      await settle();

      cubit.languagesChanged(from: french, to: LanguageEntity.english);
      conversation.gate!.complete();
      await sending;

      expect(cubit.state.turns, isEmpty);
    });

    test('the same pair changes nothing', () async {
      await speakOneTurn();

      cubit.languagesChanged(
        from: LanguageEntity.english,
        to: LanguageEntity.arabic,
      );

      expect(cubit.state.turns, hasLength(1));
    });
  });

  group('microphone access', () {
    test('coming back with the mic allowed leaves the denied state', () async {
      recorder.permitted = false;
      await cubit.micTapped();
      recorder.permitted = true;

      await cubit.appResumed();

      expect(cubit.state.status, isA<ConversationIdle>());
    });

    test('coming back still denied stays denied', () async {
      recorder.permitted = false;
      await cubit.micTapped();

      await cubit.appResumed();

      expect(cubit.state.status, isA<ConversationMicDenied>());
    });

    test('openMicSettings opens the system settings', () async {
      await cubit.openMicSettings();

      expect(recorder.settingsOpened, 1);
    });
  });

  test('speakTurn reads a turn aloud', () async {
    await cubit.speakTurn(testTurn());

    expect(tts.spoken.single, (testTurn().translation, 'ar'));
  });

  test('speakTurn is ignored while recording', () async {
    await cubit.micTapped();

    await cubit.speakTurn(testTurn());

    expect(tts.spoken, isEmpty);
  });

  test('closing cancels a turn being recorded', () async {
    await cubit.micTapped();

    await cubit.close();

    expect(recorder.cancels, 1);
  });
}
