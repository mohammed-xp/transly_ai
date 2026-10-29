import 'dart:async';

import 'package:transly_ai/core/domain/entities/language_entity.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/services/connectivity_service.dart';
import 'package:transly_ai/core/services/tts_service.dart';
import 'package:transly_ai/features/conversation/domain/entities/conversation_turn.dart';
import 'package:transly_ai/features/conversation/domain/entities/recorded_audio.dart';
import 'package:transly_ai/features/conversation/domain/entities/turn_result.dart';
import 'package:transly_ai/features/conversation/domain/repos/conversation_repo.dart';
import 'package:transly_ai/features/conversation/domain/repos/voice_recorder_repo.dart';
import 'package:transly_ai/features/conversation/domain/usecases/cancel_recording_usecase.dart';
import 'package:transly_ai/features/conversation/domain/usecases/check_mic_permission_usecase.dart';
import 'package:transly_ai/features/conversation/domain/usecases/discard_recording_usecase.dart';
import 'package:transly_ai/features/conversation/domain/usecases/open_mic_settings_usecase.dart';
import 'package:transly_ai/features/conversation/domain/usecases/request_mic_permission_usecase.dart';
import 'package:transly_ai/features/conversation/domain/usecases/send_conversation_turn_usecase.dart';
import 'package:transly_ai/features/conversation/domain/usecases/start_recording_usecase.dart';
import 'package:transly_ai/features/conversation/domain/usecases/stop_recording_usecase.dart';
import 'package:transly_ai/features/conversation/domain/usecases/watch_connection_usecase.dart';
import 'package:transly_ai/features/conversation/presentation/cubit/conversation_cubit.dart';
import 'package:transly_ai/features/conversation/presentation/cubit/conversation_state.dart';
import 'package:transly_ai/features/profile/domain/usecases/get_plan_usage_usecase.dart';
import 'package:transly_ai/features/translate/domain/usecases/speak_text_usecase.dart';

import 'fake_plan_usage_repo.dart';

const testRecording = RecordedAudio(
  path: 'turn.wav',
  duration: Duration(seconds: 2),
);

ConversationTurn testTurn({
  LanguageEntity language = LanguageEntity.english,
  String text = 'Hi! Do you know a good place for lunch nearby?',
  String translation = 'مرحباً! هل تعرف مكاناً جيداً لتناول الغداء قريباً؟',
}) => ConversationTurn(
  language: language,
  translationLanguage: language == LanguageEntity.english
      ? LanguageEntity.arabic
      : LanguageEntity.english,
  text: text,
  translation: translation,
  spokenAt: DateTime(2026, 10, 28, 10, 24),
);

class FakeVoiceRecorderRepo implements VoiceRecorderRepo {
  bool permitted = true;
  ApiResult<void> startResult = const ApiResult.success(null);
  ApiResult<RecordedAudio> stopResult = const ApiResult.success(testRecording);

  int permissionRequests = 0;
  int starts = 0;
  int stops = 0;
  int cancels = 0;
  int settingsOpened = 0;
  final List<RecordedAudio> discarded = [];

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return permitted;
  }

  @override
  Future<bool> hasPermission() async => permitted;

  @override
  Future<void> openSettings() async => settingsOpened++;

  @override
  Future<ApiResult<void>> start() async {
    starts++;
    return startResult;
  }

  @override
  Future<ApiResult<RecordedAudio>> stop() async {
    stops++;
    return stopResult;
  }

  @override
  Future<void> cancel() async => cancels++;

  @override
  Future<void> discard(RecordedAudio audio) async => discarded.add(audio);
}

typedef SentTurn = ({
  RecordedAudio audio,
  LanguageEntity languageA,
  LanguageEntity languageB,
  List<ConversationTurn> history,
});

/// Answers each turn with [result]; a [gate] holds the answer back.
class FakeConversationRepo implements ConversationRepo {
  FakeConversationRepo([ApiResult<TurnResult>? result])
    : result = result ?? ApiResult.success(TurnTranslated(testTurn()));

  ApiResult<TurnResult> result;
  Completer<void>? gate;
  final List<SentTurn> sent = [];

  @override
  Future<ApiResult<TurnResult>> sendTurn({
    required RecordedAudio audio,
    required LanguageEntity languageA,
    required LanguageEntity languageB,
    required List<ConversationTurn> history,
  }) async {
    sent.add((
      audio: audio,
      languageA: languageA,
      languageB: languageB,
      history: history,
    ));
    await gate?.future;
    return result;
  }
}

class FakeTts implements TtsService {
  final List<(String, String)> spoken = [];
  int stops = 0;

  @override
  Future<void> speak({
    required String text,
    required String languageCode,
  }) async => spoken.add((text, languageCode));

  @override
  Future<void> stop() async => stops++;
}

class FakeConnectivity implements ConnectivityService {
  FakeConnectivity({this.connected = true});

  bool connected;
  final StreamController<bool> changes = StreamController<bool>.broadcast();

  void emit(bool value) {
    connected = value;
    changes.add(value);
  }

  @override
  Future<bool> get isConnected async => connected;

  @override
  Stream<bool> get onConnectedChanged => changes.stream;

  @override
  Future<bool> get isOnWifi async => connected;
}

ConversationCubit buildConversationCubit({
  FakeVoiceRecorderRepo? recorder,
  FakeConversationRepo? conversation,
  FakeTts? tts,
  FakeConnectivity? connectivity,
  FakePlanUsageRepo? usage,
  ConversationState? initialState,
}) {
  final recorderRepo = recorder ?? FakeVoiceRecorderRepo();
  return ConversationCubit(
    requestMicPermission: RequestMicPermissionUseCase(recorderRepo),
    checkMicPermission: CheckMicPermissionUseCase(recorderRepo),
    openMicSettings: OpenMicSettingsUseCase(recorderRepo),
    startRecording: StartRecordingUseCase(recorderRepo),
    stopRecording: StopRecordingUseCase(recorderRepo),
    cancelRecording: CancelRecordingUseCase(recorderRepo),
    discardRecording: DiscardRecordingUseCase(recorderRepo),
    sendTurn: SendConversationTurnUseCase(
      conversation ?? FakeConversationRepo(),
    ),
    speakText: SpeakTextUseCase(tts ?? FakeTts()),
    getPlanUsage: GetPlanUsageUseCase(
      usage ?? FakePlanUsageRepo(ApiResult.success(testFreeUsage)),
    ),
    watchConnection: WatchConnectionUseCase(connectivity ?? FakeConnectivity()),
    initialState: initialState,
  );
}
