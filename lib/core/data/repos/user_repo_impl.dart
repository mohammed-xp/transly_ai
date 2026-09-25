import '../../domain/entities/user_entity.dart';
import '../../domain/repos/user_repo.dart';
import '../datasources/user_local_data_source.dart';

class UserRepoImpl implements UserRepo {
  const UserRepoImpl(this._userLocalDataSource);

  final UserLocalDataSource _userLocalDataSource;

  @override
  UserEntity? getCachedUser() =>
      _userLocalDataSource.getCachedUserData()?.toEntity();
}
