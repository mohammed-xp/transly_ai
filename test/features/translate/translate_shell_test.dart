import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:transly_ai/core/di/injection.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/router/app_router.dart';
import 'package:transly_ai/core/router/app_routes.dart';
import 'package:transly_ai/core/theme/app_dimens.dart';
import 'package:transly_ai/core/theme/app_theme.dart';
import 'package:transly_ai/core/services/tts_service.dart';
import 'package:transly_ai/features/translate/domain/entities/language.dart';
import 'package:transly_ai/features/translate/domain/entities/translation_engine.dart';
import 'package:transly_ai/features/translate/domain/entities/translation_entity.dart';
import 'package:transly_ai/features/translate/domain/entities/translation_tone.dart';
import 'package:transly_ai/features/translate/domain/repos/translation_repository.dart';
import 'package:transly_ai/features/translate/domain/usecases/check_translation_models_usecase.dart';
import 'package:transly_ai/features/translate/domain/usecases/download_translation_models_usecase.dart';
import 'package:transly_ai/features/translate/domain/usecases/speak_text_usecase.dart';
import 'package:transly_ai/features/translate/domain/usecases/translate_text_usecase.dart';
import 'package:transly_ai/features/translate/domain/usecases/watch_online_availability_usecase.dart';
import 'package:transly_ai/features/translate/presentation/cubit/translate_cubit.dart';
import 'package:transly_ai/features/translate/presentation/widgets/input_dock.dart';
import 'package:transly_ai/features/translate/presentation/widgets/language_bar.dart';
import 'package:transly_ai/features/translate/presentation/widgets/source_card.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

/// Deterministic in-memory repository — no delay, no online availability by
/// default — matching the fake in `translate_cubit_test.dart` (no mocking
/// framework in this repo).
class _FakeTranslationRepository implements TranslationRepository {
  @override
  Future<ApiResult<bool>> areModelsDownloaded({
    required Language from,
    required Language to,
  }) async => const ApiResult.success(true);

  @override
  Future<ApiResult<void>> downloadModels({
    required Language from,
    required Language to,
  }) async => const ApiResult.success(null);

  @override
  Future<ApiResult<TranslationEntity>> translate({
    required String text,
    required Language from,
    required Language to,
    required TranslationTone tone,
  }) async => ApiResult.success(
    TranslationEntity(
      sourceText: text,
      translatedText: 'x:$text',
      from: from,
      to: to,
      engine: TranslationEngine.offline,
    ),
  );

  @override
  Stream<bool> watchOnlineAvailability() => const Stream.empty();
}

class _FakeTtsService implements TtsService {
  @override
  Future<void> speak({required String text, required String languageCode}) =>
      Future<void>.value();

  @override
  Future<void> stop() => Future<void>.value();
}

/// The shell resolves `TranslateCubit` from `get_it`, so the fake is wired in
/// there rather than by swapping the widget out (matches `sign_in_screen_test.dart`).
void _registerCubit(_FakeTranslationRepository repo) {
  sl.registerFactory(
    () => TranslateCubit(
      translateText: TranslateTextUseCase(repo),
      checkModels: CheckTranslationModelsUseCase(repo),
      downloadModels: DownloadTranslationModelsUseCase(repo),
      speakText: SpeakTextUseCase(_FakeTtsService()),
      watchOnlineAvailability: WatchOnlineAvailabilityUseCase(repo),
    ),
  );
}

Widget _harness() {
  // Imports the real production route so the test exercises the exact shell
  // the app ships, not a copy that could drift from it.
  final router = GoRouter(
    initialLocation: AppRoutes.translate,
    routes: [translateShellRoute],
  );

  return MaterialApp.router(
    routerConfig: router,
    theme: AppTheme.light,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
  );
}

void main() {
  final en = lookupAppLocalizations(const Locale('en'));

  tearDown(sl.reset);

  group('TranslateShell', () {
    testWidgets('the keyboard tab renders the chrome and the source card', (
      tester,
    ) async {
      _registerCubit(_FakeTranslationRepository());
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(find.text('Transly'), findsOneWidget);
      expect(find.byType(LanguageBar), findsOneWidget);
      expect(find.byType(InputDock), findsOneWidget);
      expect(find.byType(SourceCard), findsOneWidget);
    });

    testWidgets('tapping Voice swaps only the middle content — the chrome '
        'stays put', (tester) async {
      _registerCubit(_FakeTranslationRepository());
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.tap(find.text(en.translateDockVoice));
      await tester.pumpAndSettle();

      expect(find.byType(InputDock), findsOneWidget);
      expect(find.text('Transly'), findsOneWidget);
      expect(find.byType(LanguageBar), findsOneWidget);
      expect(find.text(en.conversationComingSoonTitle), findsOneWidget);
    });

    testWidgets('the keyboard branch stays mounted offstage, not destroyed', (
      tester,
    ) async {
      _registerCubit(_FakeTranslationRepository());
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.tap(find.text(en.translateDockVoice));
      await tester.pumpAndSettle();

      expect(find.byType(SourceCard), findsNothing);
      expect(
        find.byType(SourceCard, skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('the cubit instance survives switching tabs — typed text '
        'is preserved', (tester) async {
      _registerCubit(_FakeTranslationRepository());
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump(TranslateCubit.debounceDuration);
      await tester.pumpAndSettle();

      await tester.tap(find.text(en.translateDockVoice));
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.translateDockKeyboard));
      await tester.pumpAndSettle();

      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('the camera tab shows its placeholder with the dock intact', (
      tester,
    ) async {
      _registerCubit(_FakeTranslationRepository());
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.tap(find.text(en.translateDockCamera));
      await tester.pumpAndSettle();

      expect(find.text(en.cameraScanComingSoonTitle), findsOneWidget);
      expect(find.byType(InputDock), findsOneWidget);
    });

    testWidgets('tapping the already-active tab is a no-op', (tester) async {
      _registerCubit(_FakeTranslationRepository());
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.tap(find.text(en.translateDockKeyboard));
      await tester.pumpAndSettle();

      expect(find.byType(SourceCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the keyboard being open hides the dock but keeps the '
        'header and language bar', (tester) async {
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);

      _registerCubit(_FakeTranslationRepository());
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(find.byType(InputDock), findsNothing);
      expect(find.text('Transly'), findsOneWidget);
      expect(find.byType(LanguageBar), findsOneWidget);
    });

    // Regression test: `TranslateScreen`'s own `MediaQuery.viewInsetsOf` read
    // is always zero once it is rendered inside `TranslateShell`'s `Scaffold`
    // body (the `Scaffold` already consumed the real inset for its layout),
    // so the shell — not the branch — must supply the gap the dock leaves
    // behind when the keyboard hides it.
    testWidgets('the shell fills the dock-sized gap itself while the '
        'keyboard is open', (tester) async {
      _registerCubit(_FakeTranslationRepository());
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      // `SafeArea` also wraps its child in a `Padding`, further up the tree
      // than the shell's own — the nearest one to the `ListView` is the
      // shell's.
      Padding contentPadding() => tester
          .widgetList<Padding>(
            find.ancestor(
              of: find.byType(ListView),
              matching: find.byType(Padding),
            ),
          )
          .first;

      expect(contentPadding().padding.resolve(TextDirection.ltr).bottom, 0);

      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();

      expect(
        contentPadding().padding.resolve(TextDirection.ltr).bottom,
        AppDimens.spaceL,
      );
    });

    testWidgets('system back from the voice tab returns to the keyboard tab', (
      tester,
    ) async {
      _registerCubit(_FakeTranslationRepository());
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.tap(find.text(en.translateDockVoice));
      await tester.pumpAndSettle();
      expect(find.text(en.conversationComingSoonTitle), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(SourceCard), findsOneWidget);
      expect(find.text(en.conversationComingSoonTitle), findsNothing);
    });
  });
}
