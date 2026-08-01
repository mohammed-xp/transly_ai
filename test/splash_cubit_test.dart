import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:transly_ai/features/splash/presentation/cubit/splash_state.dart';

void main() {
  group('SplashCubit', () {
    test('starts as SplashInitial', () {
      final cubit = SplashCubit();
      expect(cubit.state, const SplashInitial());
      cubit.close();
    });

    test('emits SplashComplete after start() finishes', () async {
      final cubit = SplashCubit(minDisplayDuration: Duration.zero);
      final expectation = expectLater(cubit.stream, emits(const SplashComplete()));

      await cubit.start();
      await expectation;
      await cubit.close();
    });
  });
}
