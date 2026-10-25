import '../../../../core/errors/failure.dart';
import '../../domain/entities/app_info_entity.dart';

sealed class AppInfoState {
  const AppInfoState();
}

class AppInfoLoading extends AppInfoState {
  const AppInfoLoading();
}

class AppInfoLoaded extends AppInfoState {
  const AppInfoLoaded(this.info);

  final AppInfoEntity info;
}

class AppInfoFailed extends AppInfoState {
  const AppInfoFailed(this.failure);

  final Failure failure;
}
