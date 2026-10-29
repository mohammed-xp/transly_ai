import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/domain/entities/language_entity.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/theme/app_palette.dart';
import 'package:transly_ai/core/widgets/toast/app_toast_scope.dart';
import 'package:transly_ai/features/conversation/domain/entities/conversation_turn.dart';
import 'package:transly_ai/features/conversation/domain/entities/turn_result.dart';
import 'package:transly_ai/features/conversation/presentation/cubit/conversation_cubit.dart';
import 'package:transly_ai/features/conversation/presentation/cubit/conversation_state.dart';
import 'package:transly_ai/features/conversation/presentation/screens/conversation_screen.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

import '../../../../helpers/conversation_cubit_factory.dart';

void main() {
  final question = testTurn();
  final answer = testTurn(
    language: LanguageEntity.arabic,
    text: 'نعم، يوجد مطعم رائع على بُعد دقيقتين من هنا.',
    translation: "Yes, there's a great restaurant two minutes from here.",
  );

  ConversationState stateWith({
    List<ConversationTurn> turns = const [],
    ConversationStatus status = const ConversationIdle(),
  }) => ConversationState.initial().copyWith(turns: turns, status: status);

  Future<ConversationCubit> pumpScreen(
    WidgetTester tester, {
    ConversationState? state,
    FakeVoiceRecorderRepo? recorder,
    FakeConversationRepo? conversation,
    FakeTts? tts,
    bool connected = true,
    Locale locale = const Locale('en'),
    Size size = const Size(402, 874),
  }) async {
    tester.view.physicalSize = size * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final cubit = buildConversationCubit(
      initialState: state,
      recorder: recorder,
      conversation: conversation,
      tts: tts,
      connectivity: FakeConnectivity(connected: connected),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [AppPalette.light]),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => AppToastScope(child: child!),
        home: Scaffold(
          body: BlocProvider(
            // Owned by the provider, which closes it when the tree goes.
            create: (_) => cubit,
            child: const ConversationScreen(),
          ),
        ),
      ),
    );
    await tester.pump();
    return cubit;
  }

  group('empty', () {
    testWidgets('invites speaking either language', (tester) async {
      await pumpScreen(tester);

      expect(find.text('Just speak'), findsOneWidget);
      expect(
        find.textContaining('English or Arabic — the language is detected'),
        findsOneWidget,
      );
      expect(
        find.text('Tap the mic and speak either language'),
        findsOneWidget,
      );
    });

    testWidgets('the read-aloud switch turns read-aloud off', (tester) async {
      final cubit = await pumpScreen(tester);

      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(cubit.state.readAloud, isFalse);
    });
  });

  testWidgets('shows each turn with its translation, language and time', (
    tester,
  ) async {
    await pumpScreen(tester, state: stateWith(turns: [question, answer]));

    expect(find.text(question.text), findsOneWidget);
    expect(find.text(question.translation), findsOneWidget);
    expect(find.text(answer.text), findsOneWidget);
    expect(find.text('English · 10:24'), findsOneWidget);
    expect(find.text('العربية · 10:24'), findsOneWidget);
  });

  testWidgets('recording shows the detecting pill', (tester) async {
    await pumpScreen(
      tester,
      state: stateWith(
        turns: [question],
        status: const ConversationRecording(),
      ),
    );

    expect(find.text('Detecting language…'), findsOneWidget);
    expect(find.text('English or العربية'), findsOneWidget);
    expect(find.text('Listening · English or العربية'), findsOneWidget);
  });

  testWidgets('a turn on its way shows it is translating', (tester) async {
    await pumpScreen(
      tester,
      state: stateWith(
        turns: [question],
        status: const ConversationTranslating(),
      ),
    );

    expect(find.text('Translating…'), findsNWidgets(2));
  });

  testWidgets('offline shows the banner', (tester) async {
    await pumpScreen(
      tester,
      state: stateWith(turns: [question]),
      connected: false,
    );

    expect(find.text("You're offline"), findsOneWidget);
    expect(find.text('Offline · microphone paused'), findsOneWidget);
  });

  testWidgets('offline still fits a short screen', (tester) async {
    await pumpScreen(tester, connected: false, size: const Size(402, 90));

    expect(tester.takeException(), isNull);
    expect(find.text("You're offline"), findsOneWidget);
  });

  testWidgets('out of time says when the time comes back', (tester) async {
    await pumpScreen(
      tester,
      state: ConversationState.initial().copyWith(
        secondsRemaining: 0,
        quotaResetsAt: DateTime(2026, 10, 29, 3),
      ),
    );

    expect(
      find.text('Conversation time used up · back at 03:00'),
      findsOneWidget,
    );
  });

  group('mic denied', () {
    testWidgets('asks for microphone access', (tester) async {
      await pumpScreen(
        tester,
        state: stateWith(status: const ConversationMicDenied()),
      );

      expect(find.text('Microphone access needed'), findsOneWidget);
      expect(find.text('Microphone is off'), findsOneWidget);
      expect(find.text('Just speak'), findsNothing);
    });

    testWidgets('Open Settings opens the system settings', (tester) async {
      final recorder = FakeVoiceRecorderRepo();
      await pumpScreen(
        tester,
        recorder: recorder,
        state: stateWith(status: const ConversationMicDenied()),
      );

      await tester.tap(find.text('Open Settings'));
      await tester.pump();

      expect(recorder.settingsOpened, 1);
    });
  });

  testWidgets('copying a turn copies its translation', (tester) async {
    final copied = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') copied.add(call.arguments);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await pumpScreen(tester, state: stateWith(turns: [question]));

    await tester.tap(find.byTooltip('Copy'));
    await tester.pump();

    expect(copied, [
      {'text': question.translation},
    ]);
    expect(find.text('Translation copied'), findsOneWidget);
  });

  group('notices', () {
    Future<void> sendTurn(WidgetTester tester, ConversationCubit cubit) async {
      await cubit.micTapped();
      await cubit.micTapped();
      await tester.pump();
    }

    testWidgets('no speech says to try again', (tester) async {
      final cubit = await pumpScreen(
        tester,
        conversation: FakeConversationRepo(
          const ApiResult.success(TurnNoSpeech()),
        ),
      );

      await sendTurn(tester, cubit);

      expect(find.text("Didn't catch that — try again."), findsOneWidget);
    });

    testWidgets('another language says to check the languages', (tester) async {
      final cubit = await pumpScreen(
        tester,
        conversation: FakeConversationRepo(
          const ApiResult.success(TurnUnsupportedLanguage()),
        ),
      );

      await sendTurn(tester, cubit);

      expect(
        find.text(
          "That didn't sound like English or Arabic. Check the languages "
          'you picked.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('a network failure offers to retry', (tester) async {
      final cubit = await pumpScreen(
        tester,
        conversation: FakeConversationRepo(
          const ApiResult.failure(NetworkFailure()),
        ),
      );

      await sendTurn(tester, cubit);

      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('a language without a voice says it cannot be read aloud', (
      tester,
    ) async {
      final tts = FakeTts()
        ..result = const ApiResult.failure(VoiceUnavailableFailure());
      final cubit = await pumpScreen(tester, tts: tts);

      await sendTurn(tester, cubit);
      await tester.pump();

      expect(
        find.text("This language can't be read aloud on your device."),
        findsOneWidget,
      );
    });
  });

  testWidgets('reads in Arabic, right to left', (tester) async {
    await pumpScreen(tester, locale: const Locale('ar'));

    expect(find.text('تحدّث فقط'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(ConversationScreen))),
      TextDirection.rtl,
    );
  });
}
