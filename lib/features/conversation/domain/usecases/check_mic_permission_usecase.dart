import '../repos/voice_recorder_repo.dart';

/// Whether the microphone may be used, without asking — e.g. after the user
/// comes back from the system settings.
class CheckMicPermissionUseCase {
  const CheckMicPermissionUseCase(this._repo);

  final VoiceRecorderRepo _repo;

  Future<bool> call() => _repo.hasPermission();
}
