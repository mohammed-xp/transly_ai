import '../entities/sign_in_method.dart';
import '../repos/user_repo.dart';

class GetSignInMethodUseCase {
  const GetSignInMethodUseCase(this._userRepo);

  final UserRepo _userRepo;

  SignInMethod call() => _userRepo.getSignInMethod();
}
