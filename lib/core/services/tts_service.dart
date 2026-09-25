abstract class TtsService {
  Future<void> speak({required String text, required String languageCode});

  Future<void> stop();
}
