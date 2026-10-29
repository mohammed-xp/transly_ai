import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../domain/entities/recorded_audio.dart';
import 'voice_recorder_data_source.dart';

/// Records WAV, 16 kHz mono 16-bit PCM — what the conversation API reads —
/// into the app's temporary directory.
class VoiceRecorderDataSourceImpl implements VoiceRecorderDataSource {
  VoiceRecorderDataSourceImpl(this._recorder);

  final AudioRecorder _recorder;

  static const RecordConfig _config = RecordConfig(
    encoder: AudioEncoder.wav,
    sampleRate: 16000,
    numChannels: 1,
  );

  final Stopwatch _elapsed = Stopwatch();

  @override
  Future<bool> hasPermission({required bool request}) =>
      _recorder.hasPermission(request: request);

  @override
  Future<void> openSettings() => openAppSettings();

  @override
  Future<void> start() async {
    final directory = await getTemporaryDirectory();
    final path =
        '${directory.path}/turn_${DateTime.now().microsecondsSinceEpoch}.wav';
    await _recorder.start(_config, path: path);
    _elapsed
      ..reset()
      ..start();
  }

  @override
  Future<RecordedAudio> stop() async {
    final path = await _recorder.stop();
    _elapsed.stop();
    if (path == null) throw StateError('Nothing was being recorded');
    return RecordedAudio(path: path, duration: _elapsed.elapsed);
  }

  @override
  Future<void> cancel() async {
    _elapsed.stop();
    await _recorder.cancel();
  }

  @override
  Future<void> delete(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
