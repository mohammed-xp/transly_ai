import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/api_result.dart';
import '../../../profile/domain/usecases/get_plan_usage_usecase.dart';
import '../../../translate/domain/usecases/speak_text_usecase.dart';
import '../../domain/entities/conversation_turn.dart';
import '../../domain/entities/recorded_audio.dart';
import '../../domain/entities/turn_result.dart';
import '../../domain/usecases/cancel_recording_usecase.dart';
import '../../domain/usecases/check_mic_permission_usecase.dart';
import '../../domain/usecases/discard_recording_usecase.dart';
import '../../domain/usecases/open_mic_settings_usecase.dart';
import '../../domain/usecases/request_mic_permission_usecase.dart';
import '../../domain/usecases/send_conversation_turn_usecase.dart';
import '../../domain/usecases/start_recording_usecase.dart';
import '../../domain/usecases/stop_recording_usecase.dart';
import '../../domain/usecases/watch_connection_usecase.dart';
import 'conversation_state.dart';

/// The voice tab: tap the mic to record a turn, tap again to have it
/// translated. The translation is read aloud when [ConversationState.readAloud]
/// is on.
class ConversationCubit extends Cubit<ConversationState> {
  ConversationCubit({
    required RequestMicPermissionUseCase requestMicPermission,
    required CheckMicPermissionUseCase checkMicPermission,
    required OpenMicSettingsUseCase openMicSettings,
    required StartRecordingUseCase startRecording,
    required StopRecordingUseCase stopRecording,
    required CancelRecordingUseCase cancelRecording,
    required DiscardRecordingUseCase discardRecording,
    required SendConversationTurnUseCase sendTurn,
    required SpeakTextUseCase speakText,
    required GetPlanUsageUseCase getPlanUsage,
    required WatchConnectionUseCase watchConnection,
    ConversationState? initialState,
  }) : _requestMicPermission = requestMicPermission,
       _checkMicPermission = checkMicPermission,
       _openMicSettings = openMicSettings,
       _startRecording = startRecording,
       _stopRecording = stopRecording,
       _cancelRecording = cancelRecording,
       _discardRecording = discardRecording,
       _sendTurn = sendTurn,
       _speakText = speakText,
       _getPlanUsage = getPlanUsage,
       super(initialState ?? ConversationState.initial()) {
    _connection = watchConnection().listen(_connectionChanged);
  }

  final RequestMicPermissionUseCase _requestMicPermission;
  final CheckMicPermissionUseCase _checkMicPermission;
  final OpenMicSettingsUseCase _openMicSettings;
  final StartRecordingUseCase _startRecording;
  final StopRecordingUseCase _stopRecording;
  final CancelRecordingUseCase _cancelRecording;
  final DiscardRecordingUseCase _discardRecording;
  final SendConversationTurnUseCase _sendTurn;
  final SpeakTextUseCase _speakText;
  final GetPlanUsageUseCase _getPlanUsage;

  late final StreamSubscription<bool> _connection;

  /// Bumped whenever the conversation starts over, so a reply that arrives
  /// for the old one is dropped.
  int _session = 0;

  /// The recording being translated, kept after a failure to send again.
  RecordedAudio? _pending;

  Timer? _maxDuration;
  bool _starting = false;

  /// A new pair of languages starts a new conversation.
  void languagesChanged({
    required LanguageEntity from,
    required LanguageEntity to,
  }) {
    if (from == state.from && to == state.to) return;
    _session++;
    _dropPending();
    if (state.status is ConversationRecording) unawaited(_abandonRecording());
    emit(
      state.copyWith(
        from: from,
        to: to,
        turns: const [],
        status: state.status is ConversationMicDenied
            ? null
            : const ConversationIdle(),
        canRetry: false,
      ),
    );
  }

  /// Reads the conversation time left. On failure the mic stays usable: the
  /// server still checks the time on every turn.
  Future<void> refreshQuota() async {
    final result = await _getPlanUsage();
    if (isClosed) return;
    if (result case ApiSuccess(:final data)) {
      final remaining = data.audioSecondsRemaining;
      if (remaining == null) return;
      emit(
        state.copyWith(
          secondsRemaining: remaining,
          quotaResetsAt: data.resetsAt,
        ),
      );
    }
  }

  Future<void> micTapped() async {
    switch (state.status) {
      case ConversationIdle():
        await _beginRecording();
      case ConversationRecording():
        await _finishRecording();
      case ConversationTranslating() || ConversationMicDenied():
        return;
    }
  }

  Future<void> retryLastTurn() async {
    final audio = _pending;
    if (audio == null ||
        state.status is! ConversationIdle ||
        !state.canUseMic) {
      return;
    }
    emit(
      state.copyWith(status: const ConversationTranslating(), canRetry: false),
    );
    await _translate(audio);
  }

  /// Plays [turn]'s translation; not while recording, or the phone would
  /// hear itself.
  Future<void> speakTurn(ConversationTurn turn) async {
    if (state.status is ConversationRecording) return;
    await _speak(turn);
  }

  void setReadAloud(bool value) {
    if (value == state.readAloud) return;
    emit(state.copyWith(readAloud: value));
  }

  Future<void> openMicSettings() => _openMicSettings();

  /// Back from the background — possibly from the settings, with the mic now
  /// allowed.
  Future<void> appResumed() async {
    if (state.status is! ConversationMicDenied) return;
    final granted = await _checkMicPermission();
    if (granted && !isClosed && state.status is ConversationMicDenied) {
      emit(state.copyWith(status: const ConversationIdle()));
    }
  }

  /// The tab or the app was left: speech stops and a turn being recorded is
  /// thrown away.
  Future<void> pause() async {
    unawaited(_speakText.stop());
    await _abandonRecording();
  }

  Future<void> _beginRecording() async {
    if (_starting || !state.canUseMic) return;
    _starting = true;
    try {
      await _speakText.stop();
      if (!await _requestMicPermission()) {
        if (!isClosed) {
          emit(state.copyWith(status: const ConversationMicDenied()));
        }
        return;
      }
      _dropPending();
      final session = _session;
      final result = await _startRecording();
      if (isClosed) return;
      switch (result) {
        case ApiFailure(:final failure):
          emit(state.copyWith(notice: RecordingFailedNotice(failure)));
        case ApiSuccess():
          // Things may have changed while the recorder was starting.
          if (session != _session ||
              !state.canUseMic ||
              state.status is! ConversationIdle) {
            await _cancelRecording();
            return;
          }
          _maxDuration = Timer(RecordedAudio.maxDuration, _finishRecording);
          emit(
            state.copyWith(
              status: const ConversationRecording(),
              canRetry: false,
            ),
          );
      }
    } finally {
      _starting = false;
    }
  }

  Future<void> _finishRecording() async {
    if (state.status is! ConversationRecording) return;
    _maxDuration?.cancel();
    emit(state.copyWith(status: const ConversationTranslating()));
    final result = await _stopRecording();
    if (isClosed) return;
    switch (result) {
      case ApiFailure(:final failure):
        emit(
          state.copyWith(
            status: const ConversationIdle(),
            notice: RecordingFailedNotice(failure),
          ),
        );
      case ApiSuccess(data: final audio):
        _pending = audio;
        await _translate(audio);
    }
  }

  Future<void> _translate(RecordedAudio audio) async {
    final session = _session;
    final result = await _sendTurn(
      audio: audio,
      languageA: state.from,
      languageB: state.to,
      previousTurns: state.turns,
    );
    if (isClosed || session != _session) return;
    switch (result) {
      case ApiSuccess(:final data):
        _dropPending();
        _showResult(data);
      case ApiFailure(:final failure):
        _showFailure(failure);
    }
  }

  void _showResult(TurnResult result) {
    final idle = state.copyWith(
      status: const ConversationIdle(),
      secondsRemaining: result.secondsRemaining,
      canRetry: false,
    );
    switch (result) {
      case TurnTranslated(:final turn):
        emit(idle.copyWith(turns: [...state.turns, turn]));
        if (state.readAloud) unawaited(_speak(turn));
      case TurnNoSpeech():
        emit(idle.copyWith(notice: NoSpeechNotice()));
      case TurnUnsupportedLanguage():
        emit(idle.copyWith(notice: UnsupportedLanguageNotice()));
    }
    // The response header says how much is left, not when it comes back.
    if (state.isOutOfTime && state.quotaResetsAt == null) {
      unawaited(refreshQuota());
    }
  }

  void _showFailure(Failure failure) {
    if (failure is TooManyRequestsFailure && failure.statusCode == 429) {
      _dropPending();
      emit(
        state.copyWith(
          status: const ConversationIdle(),
          canRetry: false,
          notice: OutOfTimeNotice(),
        ),
      );
      unawaited(refreshQuota());
      return;
    }
    final retryable = _isRetryable(failure);
    if (!retryable) _dropPending();
    emit(
      state.copyWith(
        status: const ConversationIdle(),
        canRetry: retryable,
        notice: TurnFailedNotice(failure),
      ),
    );
  }

  /// Worth sending the same recording again: the connection dropped, or the
  /// translation service was busy or slow. Anything else would fail again.
  static bool _isRetryable(Failure failure) =>
      failure is NetworkFailure ||
      (failure is ServerFailure &&
          const {502, 503, 504}.contains(failure.statusCode));

  Future<void> _speak(ConversationTurn turn) =>
      _speakText(text: turn.translation, language: turn.translationLanguage);

  Future<void> _abandonRecording() async {
    if (isClosed || state.status is! ConversationRecording) return;
    _maxDuration?.cancel();
    emit(state.copyWith(status: const ConversationIdle()));
    await _cancelRecording();
  }

  void _connectionChanged(bool connected) {
    if (state.isOffline == !connected) return;
    emit(state.copyWith(isOffline: !connected));
    if (!connected) unawaited(_abandonRecording());
  }

  void _dropPending() {
    final audio = _pending;
    _pending = null;
    if (audio != null) unawaited(_discardRecording(audio));
  }

  @override
  Future<void> close() async {
    _session++;
    _maxDuration?.cancel();
    await _connection.cancel();
    if (state.status is ConversationRecording) await _cancelRecording();
    _dropPending();
    return super.close();
  }
}
