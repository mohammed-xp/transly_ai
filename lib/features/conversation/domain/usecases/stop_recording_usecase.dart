import '../../../../core/result/api_result.dart';
import '../entities/recorded_audio.dart';
import '../repos/voice_recorder_repo.dart';

class StopRecordingUseCase {
  const StopRecordingUseCase(this._repo);

  final VoiceRecorderRepo _repo;

  Future<ApiResult<RecordedAudio>> call() => _repo.stop();
}
