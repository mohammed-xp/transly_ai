import '../repos/voice_recorder_repo.dart';

/// Opens the system settings, where a denied microphone can be allowed.
class OpenMicSettingsUseCase {
  const OpenMicSettingsUseCase(this._repo);

  final VoiceRecorderRepo _repo;

  Future<void> call() => _repo.openSettings();
}
