import '../../../../core/errors/failure.dart';
import '../../domain/entities/app_update_entity.dart';

sealed class AppUpdateState {
  const AppUpdateState();
}

class AppUpdateChecking extends AppUpdateState {
  const AppUpdateChecking();
}

/// Up to date, or the optional prompt was already shown.
class AppUpdateNone extends AppUpdateState {
  const AppUpdateNone();
}

class AppUpdateOptional extends AppUpdateState {
  const AppUpdateOptional(this.update);

  final AppUpdateEntity update;
}

class AppUpdateRequired extends AppUpdateState {
  const AppUpdateRequired(this.update);

  final AppUpdateEntity update;
}

/// The store lookup failed. Nothing is shown — the check runs again on the
/// next launch.
class AppUpdateCheckFailed extends AppUpdateState {
  const AppUpdateCheckFailed(this.failure);

  final Failure failure;
}
