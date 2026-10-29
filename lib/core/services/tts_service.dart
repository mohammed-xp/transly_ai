import '../result/api_result.dart';

abstract class TtsService {
  /// Succeeds once the speech has finished or was stopped; an engine error
  /// while speaking still counts as success. Fails with
  /// `VoiceUnavailableFailure` when the device has no voice for
  /// [languageCode], or `UnknownFailure` when the engine couldn't be asked.
  Future<ApiResult<void>> speak({
    required String text,
    required String languageCode,
  });

  Future<void> stop();
}
