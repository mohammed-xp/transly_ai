import 'package:flutter_bloc/flutter_bloc.dart';
import 'onboarding_state.dart';

final class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingInitial());

  void complete() => emit(const OnboardingComplete());
}
