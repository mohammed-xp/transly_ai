import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/conversation_turn.dart';

sealed class ConversationStatus {
  const ConversationStatus();
}

/// Waiting for the mic to be tapped.
class ConversationIdle extends ConversationStatus {
  const ConversationIdle();
}

/// The mic is on; tapping it again sends the turn.
class ConversationRecording extends ConversationStatus {
  const ConversationRecording();
}

/// The recorded turn is being translated.
class ConversationTranslating extends ConversationStatus {
  const ConversationTranslating();
}

class ConversationMicDenied extends ConversationStatus {
  const ConversationMicDenied();
}

/// Something to tell the user once. Constructors are deliberately not
/// `const`: each notice is a new object, so the same kind twice in a row is
/// still told twice.
sealed class ConversationNotice {}

/// Nothing understandable was heard.
class NoSpeechNotice extends ConversationNotice {}

/// The speech was in neither of the two languages.
class UnsupportedLanguageNotice extends ConversationNotice {}

/// The conversation time is used up.
class OutOfTimeNotice extends ConversationNotice {}

class TurnFailedNotice extends ConversationNotice {
  TurnFailedNotice(this.failure);

  final Failure failure;
}

class RecordingFailedNotice extends ConversationNotice {
  RecordingFailedNotice(this.failure);

  final Failure failure;
}

/// A translation couldn't be read aloud, e.g. no voice for its language.
class ReadAloudFailedNotice extends ConversationNotice {
  ReadAloudFailedNotice(this.failure);

  final Failure failure;
}

/// Single immutable state of the voice tab (design `Conversation v2`).
class ConversationState {
  const ConversationState({
    required this.from,
    required this.to,
    required this.turns,
    required this.status,
    required this.isOffline,
    required this.readAloud,
    this.secondsRemaining,
    this.quotaResetsAt,
    this.canRetry = false,
    this.notice,
  });

  factory ConversationState.initial() => const ConversationState(
    from: LanguageEntity.defaultSource,
    to: LanguageEntity.defaultTarget,
    turns: [],
    status: ConversationIdle(),
    isOffline: false,
    readAloud: true,
  );

  /// The two languages listened for — the home screen's pair. Turns in
  /// [from] sit on the start side, turns in [to] on the end side.
  final LanguageEntity from;
  final LanguageEntity to;

  final List<ConversationTurn> turns;
  final ConversationStatus status;
  final bool isOffline;

  /// Play each translation once it is ready.
  final bool readAloud;

  /// Conversation seconds left today; null until the server has said.
  final int? secondsRemaining;
  final DateTime? quotaResetsAt;

  /// The last turn failed and its recording is kept to send again.
  final bool canRetry;

  /// The latest thing to tell the user; see [ConversationNotice].
  final ConversationNotice? notice;

  /// Nothing said yet — the design's `Empty` screen.
  bool get isEmpty => turns.isEmpty && status is ConversationIdle;

  bool get isOutOfTime {
    final remaining = secondsRemaining;
    return remaining != null && remaining <= 0;
  }

  /// Offline or out of time, the mic can't be used.
  bool get canUseMic => !isOffline && !isOutOfTime;

  ConversationState copyWith({
    LanguageEntity? from,
    LanguageEntity? to,
    List<ConversationTurn>? turns,
    ConversationStatus? status,
    bool? isOffline,
    bool? readAloud,
    int? secondsRemaining,
    DateTime? quotaResetsAt,
    bool? canRetry,
    ConversationNotice? notice,
  }) {
    return ConversationState(
      from: from ?? this.from,
      to: to ?? this.to,
      turns: turns ?? this.turns,
      status: status ?? this.status,
      isOffline: isOffline ?? this.isOffline,
      readAloud: readAloud ?? this.readAloud,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      quotaResetsAt: quotaResetsAt ?? this.quotaResetsAt,
      canRetry: canRetry ?? this.canRetry,
      notice: notice ?? this.notice,
    );
  }
}
