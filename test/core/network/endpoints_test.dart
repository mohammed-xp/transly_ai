import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/network/endpoints.dart';

void main() {
  test('targets the production API over HTTPS unless overridden', () {
    final baseUrl = Uri.parse(Endpoints.baseUrl);

    expect(baseUrl.scheme, 'https');
    expect(
      baseUrl.host,
      'translyai-api.jollypond-1171c5b6.uaenorth.azurecontainerapps.io',
    );
  });
}
