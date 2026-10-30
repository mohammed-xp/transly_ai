import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:transly_ai/core/constants/app_icons.dart';
import 'package:transly_ai/core/di/service_locator.dart';
import 'package:transly_ai/core/domain/entities/language_entity.dart';
import 'package:transly_ai/core/domain/usecases/get_cached_user_use_case.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/router/app_routes.dart';
import 'package:transly_ai/core/theme/app_palette.dart';
import 'package:transly_ai/core/widgets/toast/app_toast_scope.dart';
import 'package:transly_ai/core/widgets/user_avatar.dart';
import 'package:transly_ai/features/app_update/domain/usecases/check_for_app_update_usecase.dart';
import 'package:transly_ai/features/app_update/domain/usecases/mark_app_update_prompted_usecase.dart';
import 'package:transly_ai/features/app_update/domain/usecases/open_app_store_usecase.dart';
import 'package:transly_ai/features/app_update/presentation/cubit/app_update_cubit.dart';
import 'package:transly_ai/features/conversation/presentation/cubit/conversation_cubit.dart';
import 'package:transly_ai/features/conversation/presentation/cubit/conversation_state.dart';
import 'package:transly_ai/features/conversation/presentation/widgets/voice_dock_tab.dart';
import 'package:transly_ai/features/home/presentation/cubit/home_cubit.dart';
import 'package:transly_ai/features/home/presentation/screens/home_shell.dart';
import 'package:transly_ai/features/home/presentation/widgets/input_dock.dart';
import 'package:transly_ai/features/home/presentation/widgets/language_bar.dart';
import 'package:transly_ai/features/home/presentation/widgets/translate_header.dart';
import 'package:transly_ai/features/language_picker/domain/entities/language_pair.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/add_recent_language_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/auto_download_offline_models_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/delete_offline_model_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/download_offline_model_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/get_cached_languages_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/get_offline_model_statuses_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/get_offline_packs_settings_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/get_recent_languages_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/get_saved_language_pair_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/save_language_pair_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/select_language_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/sync_languages_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/watch_offline_model_updates_usecase.dart';
import 'package:transly_ai/features/language_picker/presentation/cubit/auto_download_notice_cubit.dart';
import 'package:transly_ai/features/language_picker/presentation/cubit/language_picker_cubit.dart';
import 'package:transly_ai/features/profile/domain/usecases/get_cached_plan_usecase.dart';
import 'package:transly_ai/features/profile/domain/usecases/get_plan_usage_usecase.dart';
import 'package:transly_ai/features/translate/domain/usecases/get_cached_tones_usecase.dart';
import 'package:transly_ai/features/translate/domain/usecases/get_saved_tone_usecase.dart';
import 'package:transly_ai/features/translate/domain/usecases/save_tone_usecase.dart';
import 'package:transly_ai/features/translate/domain/usecases/speak_text_usecase.dart';
import 'package:transly_ai/features/translate/domain/usecases/sync_tones_usecase.dart';
import 'package:transly_ai/features/translate/domain/usecases/translate_text_usecase.dart';
import 'package:transly_ai/features/translate/domain/usecases/watch_online_availability_usecase.dart';
import 'package:transly_ai/features/translate/presentation/cubit/translate_cubit.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

import '../../../../helpers/conversation_cubit_factory.dart';
import '../../../../helpers/fake_app_update_repo.dart';
import '../../../../helpers/fake_languages_repo.dart';
import '../../../../helpers/fake_offline_models_repo.dart';
import '../../../../helpers/fake_plan_usage_repo.dart';
import '../../../../helpers/fake_translation_repo.dart';
import '../../../../helpers/fake_user_repo.dart';
import '../../../../helpers/svg_icon_finder.dart';

void main() {
  late FakeTranslationRepo translationRepo;
  late FakeVoiceRecorderRepo recorder;
  late FakeTts tts;

  setUp(() {
    translationRepo = FakeTranslationRepo();
    recorder = FakeVoiceRecorderRepo();
    tts = FakeTts();
    final languagesRepo = FakeLanguagesRepo(cached: testLanguages);
    final modelsRepo = FakeOfflineModelsRepo();
    final plans = FakePlanUsageRepo(ApiResult.success(testFreeUsage));
    serviceLocator
      ..registerFactory(
        () => HomeCubit(
          getCachedUser: GetCachedUserUseCase(FakeUserRepo(testUser)),
          getCachedPlan: GetCachedPlanUseCase(plans),
          getPlanUsage: GetPlanUsageUseCase(plans),
          getSavedLanguagePair: GetSavedLanguagePairUseCase(languagesRepo),
          saveLanguagePair: SaveLanguagePairUseCase(languagesRepo),
        ),
      )
      ..registerFactory(
        () => TranslateCubit(
          translateText: TranslateTextUseCase(
            translationRepo,
            AutoDownloadOfflineModelsUseCase(modelsRepo),
          ),
          speakText: SpeakTextUseCase(tts),
          watchOnlineAvailability: WatchOnlineAvailabilityUseCase(
            translationRepo,
          ),
          getCachedTones: GetCachedTonesUseCase(translationRepo),
          syncTones: SyncTonesUseCase(translationRepo),
          getSavedTone: GetSavedToneUseCase(translationRepo),
          saveTone: SaveToneUseCase(translationRepo),
        ),
      )
      ..registerFactory(
        () => buildConversationCubit(recorder: recorder, tts: tts),
      )
      ..registerFactory(
        () => AutoDownloadNoticeCubit(
          watchOfflineModelUpdates: WatchOfflineModelUpdatesUseCase(modelsRepo),
          getCachedLanguages: GetCachedLanguagesUseCase(languagesRepo),
          getSettings: GetOfflinePacksSettingsUseCase(modelsRepo),
        ),
      )
      ..registerFactoryParam<LanguagePickerCubit, LanguagePair, void>(
        (pair, _) => LanguagePickerCubit(
          initialPair: pair,
          getCachedLanguages: GetCachedLanguagesUseCase(languagesRepo),
          syncLanguages: SyncLanguagesUseCase(languagesRepo),
          getRecentLanguages: GetRecentLanguagesUseCase(languagesRepo),
          addRecentLanguage: AddRecentLanguageUseCase(languagesRepo),
          selectLanguage: const SelectLanguageUseCase(),
          getOfflineModelStatuses: GetOfflineModelStatusesUseCase(modelsRepo),
          watchOfflineModelUpdates: WatchOfflineModelUpdatesUseCase(modelsRepo),
          downloadOfflineModel: DownloadOfflineModelUseCase(modelsRepo),
          deleteOfflineModel: DeleteOfflineModelUseCase(modelsRepo),
        ),
      );
  });

  tearDown(serviceLocator.reset);

  Future<void> pumpShell(WidgetTester tester) async {
    tester.view.physicalSize = const Size(402, 874) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final updateRepo = FakeAppUpdateRepo();
    final updateCubit = AppUpdateCubit(
      checkForUpdate: CheckForAppUpdateUseCase(updateRepo),
      markPrompted: MarkAppUpdatePromptedUseCase(updateRepo),
      openStore: OpenAppStoreUseCase(updateRepo),
    );
    addTearDown(updateCubit.close);
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const HomeShell()),
        GoRoute(
          path: AppRoutes.profile,
          name: AppRoutes.profileName,
          builder: (_, _) => const Scaffold(body: Text('Profile')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      BlocProvider.value(
        value: updateCubit,
        child: MaterialApp.router(
          theme: ThemeData(extensions: const [AppPalette.light]),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => AppToastScope(child: child!),
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();
  }

  T read<T extends StateStreamableSource<Object?>>(WidgetTester tester) =>
      tester.element(find.byType(InputDock)).read<T>();

  Future<void> openVoice(WidgetTester tester) async {
    await tester.tap(find.text('Conversation'));
    await tester.pumpAndSettle();
  }

  Future<void> openKeyboard(WidgetTester tester) async {
    await tester.tap(find.text('Translate'));
    await tester.pumpAndSettle();
  }

  Future<void> swap(WidgetTester tester) async {
    await tester.tap(
      find.descendant(
        of: find.byType(LanguageBar),
        matching: findSvgIcon(AppIcons.swap),
      ),
    );
    await tester.pump();
  }

  Future<ConversationCubit> startRecording(WidgetTester tester) async {
    final conversation = read<ConversationCubit>(tester);
    await conversation.micTapped();
    await tester.pump();
    expect(conversation.state.status, isA<ConversationRecording>());
    return conversation;
  }

  Future<void> translateHello(WidgetTester tester) async {
    read<TranslateCubit>(tester)
      ..sourceTextChanged('hello')
      ..translateNow();
    await tester.pump();
  }

  group('Header', () {
    testWidgets('names the Translate tab on start', (tester) async {
      await pumpShell(tester);

      expect(find.text('TRANSLATE'), findsOneWidget);
    });

    testWidgets('names the Conversation tab once it opens', (tester) async {
      await pumpShell(tester);

      await openVoice(tester);

      expect(find.text('CONVERSATION'), findsOneWidget);
      expect(find.text('TRANSLATE'), findsNothing);
    });

    testWidgets('names the Camera tab once it opens', (tester) async {
      await pumpShell(tester);

      await tester.tap(find.text('Camera'));
      await tester.pumpAndSettle();

      expect(find.text('CAMERA'), findsOneWidget);
      expect(find.text('TRANSLATE'), findsNothing);
    });

    testWidgets('rolls the old tab name out during the switch', (tester) async {
      await pumpShell(tester);

      await tester.tap(find.text('Conversation'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('CONVERSATION'), findsOneWidget);
      expect(find.text('TRANSLATE'), findsOneWidget);
    });
  });

  group('Switching tabs', () {
    testWidgets('keeps what was typed on the Translate tab', (tester) async {
      await pumpShell(tester);
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();

      await openVoice(tester);
      await openKeyboard(tester);

      expect(find.widgetWithText(TextField, 'hello'), findsOneWidget);
    });

    testWidgets('the back gesture returns to Translate with the motion', (
      tester,
    ) async {
      await pumpShell(tester);
      await openVoice(tester);

      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('TRANSLATE'), findsOneWidget);
      expect(find.text('CONVERSATION'), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('CONVERSATION'), findsNothing);
    });

    testWidgets('the mic is only live on the Voice tab', (tester) async {
      await pumpShell(tester);

      await tester.tapAt(tester.getCenter(find.byType(VoiceDockTab)));
      await tester.pump();

      expect(recorder.starts, 0);
    });
  });

  group('Voice tab', () {
    testWidgets('keeps the shared header and language bar', (tester) async {
      await pumpShell(tester);

      await openVoice(tester);

      expect(find.byType(TranslateHeader), findsOneWidget);
      expect(find.byType(LanguageBar), findsOneWidget);
    });

    testWidgets('a swap starts a new conversation', (tester) async {
      await pumpShell(tester);
      await openVoice(tester);
      final conversation = read<ConversationCubit>(tester);
      await conversation.micTapped();
      await conversation.micTapped();
      await tester.pump();
      expect(conversation.state.turns, isNotEmpty);

      await swap(tester);

      expect(conversation.state.turns, isEmpty);
    });

    testWidgets('opening the profile stops the recording', (tester) async {
      await pumpShell(tester);
      await openVoice(tester);
      final conversation = await startRecording(tester);

      await tester.tap(find.byType(UserAvatar));
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsOneWidget);
      expect(conversation.state.status, isA<ConversationIdle>());
      expect(recorder.cancels, 1);
    });

    testWidgets('opening a language picker stops the recording', (
      tester,
    ) async {
      await pumpShell(tester);
      await openVoice(tester);
      final conversation = await startRecording(tester);

      await tester.tap(
        find.descendant(
          of: find.byType(LanguageBar),
          matching: find.text('English'),
        ),
      );
      await tester.pump();

      expect(conversation.state.status, isA<ConversationIdle>());
      expect(recorder.cancels, 1);
    });
  });

  group('Translate tab', () {
    testWidgets('opening the profile from it leaves speech playing', (
      tester,
    ) async {
      await pumpShell(tester);
      final stopsBefore = tts.stops;

      await tester.tap(find.byType(UserAvatar));
      await tester.pumpAndSettle();

      expect(tts.stops, stopsBefore);
    });

    testWidgets('a swap on it translates right away', (tester) async {
      await pumpShell(tester);
      await translateHello(tester);

      await swap(tester);

      expect(translationRepo.requestedTones, hasLength(2));
    });

    testWidgets('a swap from the Voice tab is not translated out of sight', (
      tester,
    ) async {
      await pumpShell(tester);
      await translateHello(tester);
      await openVoice(tester);

      await swap(tester);

      expect(translationRepo.requestedTones, hasLength(1));
    });

    testWidgets('takes the pair swapped on the Voice tab when it shows again', (
      tester,
    ) async {
      await pumpShell(tester);
      await translateHello(tester);
      await openVoice(tester);
      await swap(tester);

      await openKeyboard(tester);

      final translate = read<TranslateCubit>(tester);
      expect(translate.state.from, LanguageEntity.defaultTarget);
      expect(translate.state.to, LanguageEntity.defaultSource);
      expect(translationRepo.requestedTones, hasLength(2));
    });
  });
}
