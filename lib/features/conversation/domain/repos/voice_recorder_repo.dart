import '../../../../core/result/api_result.dart';
import '../entities/recorded_audio.dart';

abstract class VoiceRecorderRepo {
  /// Whether the app may use the microphone, asking the user if it hasn't
  /// yet.
  Future<bool> requestPermission();

  /// Whether the app may use the microphone, without asking.
  Future<bool> hasPermission();

  /// Opens the app's page in the system settings.
  Future<void> openSettings();

  Future<ApiResult<void>> start();

  Future<ApiResult<RecordedAudio>> stop();

  /// Stops and throws away the recording in progress, if any.
  Future<void> cancel();

  /// Deletes a finished recording from the device.
  Future<void> discard(RecordedAudio audio);
}
