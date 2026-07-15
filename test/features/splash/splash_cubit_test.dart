import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:transly_ai/features/splash/presentation/cubit/splash_state.dart';

void main() {
  group('SplashCubit', () {
    test('starts in SplashInitializing', () {
      final cubit = SplashCubit();
      addTearDown(cubit.close);

      expect(cubit.state, isA<SplashInitializing>());
    });

    test('start() emits SplashReady once the minimum duration elapses', () {
      fakeAsync((async) {
        final cubit = SplashCubit();
        final emitted = <SplashState>[];
        final sub = cubit.stream.listen(emitted.add);

        cubit.start();

        // Nothing one tick before the delay completes.
        async.elapse(
          SplashCubit.minSplashDuration - const Duration(milliseconds: 1),
        );
        expect(emitted, isEmpty);

        // Ready once the full duration has elapsed.
        async.elapse(const Duration(milliseconds: 1));
        async.flushMicrotasks();
        expect(emitted, [isA<SplashReady>()]);

        sub.cancel();
        cubit.close();
      });
    });

    test('does not emit after being closed', () {
      fakeAsync((async) {
        final cubit = SplashCubit();
        final emitted = <SplashState>[];
        final sub = cubit.stream.listen(emitted.add);

        cubit.start();
        cubit.close();

        async.elapse(SplashCubit.minSplashDuration + const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(emitted, isEmpty);

        sub.cancel();
      });
    });
  });
}
