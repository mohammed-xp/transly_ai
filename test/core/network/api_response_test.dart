import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/network/api_response.dart';

void main() {
  test('finds a header whatever its case', () {
    const response = ApiResponse(
      data: {},
      headers: {
        'X-Audio-Seconds-Remaining': ['258'],
      },
    );

    expect(response.header('x-audio-seconds-remaining'), '258');
  });

  test('a missing header is null', () {
    const response = ApiResponse(data: {});

    expect(response.header('retry-after'), isNull);
  });

  test('a header with no value is null', () {
    const response = ApiResponse(data: {}, headers: {'retry-after': []});

    expect(response.header('retry-after'), isNull);
  });
}
