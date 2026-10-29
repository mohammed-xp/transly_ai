import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/constants/app_icons.dart';
import 'package:transly_ai/core/theme/app_palette.dart';
import 'package:transly_ai/core/widgets/spinning_ring.dart';
import 'package:transly_ai/features/conversation/presentation/cubit/conversation_cubit.dart';
import 'package:transly_ai/features/conversation/presentation/cubit/conversation_state.dart';
import 'package:transly_ai/features/conversation/presentation/widgets/voice_dock_tab.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

import '../../../../helpers/conversation_cubit_factory.dart';
import '../../../../helpers/svg_icon_finder.dart';

void main() {
  late ConversationCubit cubit;

  Future<FakeVoiceRecorderRepo> pumpTab(
    WidgetTester tester,
    ConversationState state, {
    bool connected = true,
  }) async {
    final recorder = FakeVoiceRecorderRepo();
    cubit = buildConversationCubit(
      recorder: recorder,
      initialState: state,
      connectivity: FakeConnectivity(connected: connected),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [AppPalette.light]),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: BlocProvider(
              // Owned by the provider, which closes it when the tree goes.
              create: (_) => cubit,
              child: const VoiceDockTab(),
            ),
          ),
        ),
      ),
    );
    return recorder;
  }

  testWidgets('tapping the mic starts recording', (tester) async {
    final recorder = await pumpTab(tester, ConversationState.initial());

    await tester.tap(find.byType(VoiceDockTab));
    await tester.pump();

    expect(recorder.starts, 1);
    // Ends the recording, and with it the 30 s auto-stop timer.
    await cubit.pause();
  });

  testWidgets('tapping it while recording stops the recording', (tester) async {
    final recorder = await pumpTab(
      tester,
      ConversationState.initial().copyWith(
        status: const ConversationRecording(),
      ),
    );

    await tester.tap(find.byType(VoiceDockTab));
    await tester.pump();

    expect(recorder.stops, 1);
  });

  testWidgets('the mic is inert while offline', (tester) async {
    final recorder = await pumpTab(
      tester,
      ConversationState.initial(),
      connected: false,
    );
    await tester.pump();

    await tester.tap(find.byType(VoiceDockTab));
    await tester.pump();

    expect(recorder.starts, 0);
  });

  testWidgets('the mic is inert while a turn is translating', (tester) async {
    final recorder = await pumpTab(
      tester,
      ConversationState.initial().copyWith(
        status: const ConversationTranslating(),
      ),
    );

    await tester.tap(find.byType(VoiceDockTab));
    await tester.pump();

    expect(recorder.starts, 0);
    expect(recorder.stops, 0);
  });

  testWidgets('a translating turn shows no spinner on the mic', (tester) async {
    await pumpTab(
      tester,
      ConversationState.initial().copyWith(
        status: const ConversationTranslating(),
      ),
    );

    expect(find.byType(SpinningRing), findsNothing);
    expect(findSvgIcon(AppIcons.micFilled), findsOneWidget);
  });

  testWidgets('the mic is inert without microphone access', (tester) async {
    final recorder = await pumpTab(
      tester,
      ConversationState.initial().copyWith(
        status: const ConversationMicDenied(),
      ),
    );

    await tester.tap(find.byType(VoiceDockTab));
    await tester.pump();

    expect(recorder.permissionRequests, 0);
  });

  testWidgets('labels the tab Conversation', (tester) async {
    await pumpTab(tester, ConversationState.initial());

    expect(find.text('Conversation'), findsOneWidget);
  });
}
