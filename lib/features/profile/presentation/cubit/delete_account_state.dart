import '../../../../core/errors/failure.dart';

sealed class DeleteAccountState {
  const DeleteAccountState();

  bool get isBusy => switch (this) {
    DeleteAccountInProgress() || DeleteAccountSucceeded() => true,
    DeleteAccountInitial() || DeleteAccountFailed() => false,
  };
}

class DeleteAccountInitial extends DeleteAccountState {
  const DeleteAccountInitial();
}

class DeleteAccountInProgress extends DeleteAccountState {
  const DeleteAccountInProgress();
}

/// The session is already ending; the sheet closes when the app routes to
/// sign-in.
class DeleteAccountSucceeded extends DeleteAccountState {
  const DeleteAccountSucceeded();
}

class DeleteAccountFailed extends DeleteAccountState {
  const DeleteAccountFailed(this.failure);

  final Failure failure;
}
