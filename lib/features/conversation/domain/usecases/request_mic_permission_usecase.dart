import '../repos/voice_recorder_repo.dart';

/// Whether the microphone may be used, asking the user if needed.
class RequestMicPermissionUseCase {
  const RequestMicPermissionUseCase(this._repo);

  final VoiceRecorderRepo _repo;

  Future<bool> call() => _repo.requestPermission();
}
