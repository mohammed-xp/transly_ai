import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/conversation/data/datasources/voice_recorder_data_source.dart';
import 'package:transly_ai/features/conversation/data/repos/voice_recorder_repo_impl.dart';
import 'package:transly_ai/features/conversation/domain/entities/recorded_audio.dart';

import '../../../../helpers/conversation_cubit_factory.dart';

class _FakeRecorder implements VoiceRecorderDataSource {
  bool permitted = true;
  Object? error;
  final List<bool> permissionRequests = [];
  final List<String> deleted = [];

  void _maybeThrow() {
    final error = this.error;
    if (error != null) throw error;
  }

  @override
  Future<bool> hasPermission({required bool request}) async {
    permissionRequests.add(request);
    _maybeThrow();
    return permitted;
  }

  @override
  Future<void> openSettings() async => _maybeThrow();

  @override
  Future<void> start() async => _maybeThrow();

  @override
  Future<RecordedAudio> stop() async {
    _maybeThrow();
    return testRecording;
  }

  @override
  Future<void> cancel() async => _maybeThrow();

  @override
  Future<void> delete(String path) async {
    _maybeThrow();
    deleted.add(path);
  }
}

void main() {
  late _FakeRecorder recorder;
  late VoiceRecorderRepoImpl repo;

  setUp(() {
    recorder = _FakeRecorder();
    repo = VoiceRecorderRepoImpl(recorder);
  });

  final platformError = PlatformException(code: 'record');

  test('requestPermission asks the user', () async {
    await repo.requestPermission();

    expect(recorder.permissionRequests, [true]);
  });

  test('hasPermission does not ask the user', () async {
    await repo.hasPermission();

    expect(recorder.permissionRequests, [false]);
  });

  test('a permission that cannot be read is not granted', () async {
    recorder.error = platformError;

    expect(await repo.requestPermission(), isFalse);
  });

  test('a recorder that fails to start is a failure', () async {
    recorder.error = platformError;

    final result = await repo.start();

    expect((result as ApiFailure<void>).failure, isA<UnknownFailure>());
  });

  test('stop returns the recording', () async {
    final result = await repo.stop();

    expect((result as ApiSuccess<RecordedAudio>).data, testRecording);
  });

  test('a recorder that fails to stop is a failure', () async {
    recorder.error = platformError;

    final result = await repo.stop();

    expect(result, isA<ApiFailure<RecordedAudio>>());
  });

  test('discard deletes the recording', () async {
    await repo.discard(testRecording);

    expect(recorder.deleted, [testRecording.path]);
  });

  test('cleanup failures are not errors', () async {
    recorder.error = platformError;

    await repo.cancel();
    await repo.discard(testRecording);
    await repo.openSettings();
  });
}
