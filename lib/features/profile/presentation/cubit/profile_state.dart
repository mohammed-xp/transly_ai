import '../../../../core/domain/entities/user_entity.dart';
import '../../../../core/errors/failure.dart';

sealed class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.user);

  final UserEntity user;
}

class ProfileFailed extends ProfileState {
  const ProfileFailed(this.failure);

  final Failure failure;
}
