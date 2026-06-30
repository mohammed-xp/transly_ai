import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/error/failures.dart';

void main() {
  group('ApiResult', () {
    test('Success holds data', () {
      const result = Success<int>(42);
      expect(result.dataOrNull, 42);
      expect(result.isSuccess, isTrue);
      expect(result.isError, isFalse);
    });

    test('ApiError holds failure', () {
      const result = ApiError<int>(NetworkFailure());
      expect(result.failureOrNull, isA<NetworkFailure>());
      expect(result.isError, isTrue);
      expect(result.isSuccess, isFalse);
    });

    test('when dispatches correctly', () {
      const ApiResult<String> result = Success('hello');
      final out = result.when(
        success: (d) => 'ok:$d',
        error: (f) => 'err',
      );
      expect(out, 'ok:hello');
    });
  });
}
