import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/features/conversation/domain/usecases/watch_connection_usecase.dart';

import '../../../../helpers/conversation_cubit_factory.dart';

void main() {
  test('gives the current connection first, then each change', () async {
    final connectivity = FakeConnectivity(connected: false);
    final seen = <bool>[];
    final subscription = WatchConnectionUseCase(
      connectivity,
    )().listen(seen.add);
    await Future<void>.delayed(Duration.zero);

    connectivity.emit(true);
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(seen, [false, true]);
  });
}
