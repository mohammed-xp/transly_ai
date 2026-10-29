import '../../../../core/result/api_result.dart';
import '../repos/voice_recorder_repo.dart';

class StartRecordingUseCase {
  const StartRecordingUseCase(this._repo);

  final VoiceRecorderRepo _repo;

  Future<ApiResult<void>> call() => _repo.start();
}
