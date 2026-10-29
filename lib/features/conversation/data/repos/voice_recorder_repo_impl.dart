import '../../../../core/errors/error_mapper.dart';
import '../../../../core/result/api_result.dart';
import '../../domain/entities/recorded_audio.dart';
import '../../domain/repos/voice_recorder_repo.dart';
import '../datasources/voice_recorder_data_source.dart';

class VoiceRecorderRepoImpl implements VoiceRecorderRepo {
  VoiceRecorderRepoImpl(this._recorder);

  final VoiceRecorderDataSource _recorder;

  /// A permission that can't be read is treated as not granted.
  @override
  Future<bool> requestPermission() async {
    try {
      return await _recorder.hasPermission(request: true);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> hasPermission() async {
    try {
      return await _recorder.hasPermission(request: false);
    } catch (_) {
      return false;
    }
  }

  /// Best effort: if the settings can't be opened there is nothing else to
  /// offer, and the screen keeps explaining what to do.
  @override
  Future<void> openSettings() async {
    try {
      await _recorder.openSettings();
    } catch (_) {}
  }

  @override
  Future<ApiResult<void>> start() async {
    try {
      await _recorder.start();
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorMapper.map(e));
    }
  }

  @override
  Future<ApiResult<RecordedAudio>> stop() async {
    try {
      return ApiResult.success(await _recorder.stop());
    } catch (e) {
      return ApiResult.failure(ErrorMapper.map(e));
    }
  }

  /// Cleanup: a recorder that already stopped has nothing to cancel.
  @override
  Future<void> cancel() async {
    try {
      await _recorder.cancel();
    } catch (_) {}
  }

  /// Cleanup: the file is in the temporary directory, which the system
  /// clears anyway.
  @override
  Future<void> discard(RecordedAudio audio) async {
    try {
      await _recorder.delete(audio.path);
    } catch (_) {}
  }
}
