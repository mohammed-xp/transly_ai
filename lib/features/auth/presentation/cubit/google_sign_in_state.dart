import '../../../../core/errors/failure.dart';

sealed class GoogleSignInState {
  const GoogleSignInState();
}

class GoogleSignInInitial extends GoogleSignInState {
  const GoogleSignInInitial();
}

class GoogleSignInLoading extends GoogleSignInState {
  const GoogleSignInLoading();
}

class GoogleSignInSucceeded extends GoogleSignInState {
  const GoogleSignInSucceeded();
}

class GoogleSignInFailed extends GoogleSignInState {
  const GoogleSignInFailed(this.failure);

  final Failure failure;
}
