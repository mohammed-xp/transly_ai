import '../entities/recorded_audio.dart';
import '../repos/voice_recorder_repo.dart';

/// Deletes a finished recording once it is no longer needed.
class DiscardRecordingUseCase {
  const DiscardRecordingUseCase(this._repo);

  final VoiceRecorderRepo _repo;

  Future<void> call(RecordedAudio audio) => _repo.discard(audio);
}
