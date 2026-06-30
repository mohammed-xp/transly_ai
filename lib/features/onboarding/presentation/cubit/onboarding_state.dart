import 'package:equatable/equatable.dart';

sealed class OnboardingState extends Equatable {
  const OnboardingState();
  @override
  List<Object?> get props => [];
}

final class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

final class OnboardingComplete extends OnboardingState {
  const OnboardingComplete();
}
