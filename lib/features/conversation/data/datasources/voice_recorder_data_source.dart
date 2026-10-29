import '../../domain/entities/recorded_audio.dart';

/// The device microphone. Methods throw on platform failures.
abstract class VoiceRecorderDataSource {
  Future<bool> hasPermission({required bool request});

  Future<void> openSettings();

  Future<void> start();

  Future<RecordedAudio> stop();

  Future<void> cancel();

  Future<void> delete(String path);
}
