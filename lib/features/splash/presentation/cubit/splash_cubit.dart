import 'package:flutter_bloc/flutter_bloc.dart';

import 'splash_state.dart';

final class SplashCubit extends Cubit<SplashState> {
  SplashCubit({Duration minDisplayDuration = const Duration(milliseconds: 1600)})
      : _minDisplayDuration = minDisplayDuration,
        super(const SplashInitial());

  final Duration _minDisplayDuration;

  Future<void> start() async {
    await Future.delayed(_minDisplayDuration);
    if (!isClosed) emit(const SplashComplete());
  }
}
