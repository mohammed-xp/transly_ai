/// A finished recording of one turn, kept on the device until it has been
/// sent (or given up on).
class RecordedAudio {
  const RecordedAudio({required this.path, required this.duration});

  /// Shorter recordings hold no speech the server would process.
  static const Duration minDuration = Duration(milliseconds: 500);

  /// The longest turn the server accepts; recording stops itself there.
  static const Duration maxDuration = Duration(seconds: 30);

  final String path;
  final Duration duration;
}
