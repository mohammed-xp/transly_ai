import '../repos/voice_recorder_repo.dart';

/// Stops and throws away the recording in progress, if any.
class CancelRecordingUseCase {
  const CancelRecordingUseCase(this._repo);

  final VoiceRecorderRepo _repo;

  Future<void> call() => _repo.cancel();
}
