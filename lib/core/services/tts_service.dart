abstract class TtsService {
  /// Completes once the speech has finished or was stopped.
  Future<void> speak({required String text, required String languageCode});

  Future<void> stop();
}
