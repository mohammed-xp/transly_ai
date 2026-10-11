import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/usecases/get_cached_user_use_case.dart';
import '../../../../core/domain/usecases/get_sign_in_method_use_case.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required GetCachedUserUseCase getCachedUser,
    required GetSignInMethodUseCase getSignInMethod,
  }) : _getCachedUser = getCachedUser,
       _getSignInMethod = getSignInMethod,
       super(const ProfileInitial());

  final GetCachedUserUseCase _getCachedUser;
  final GetSignInMethodUseCase _getSignInMethod;

  void loadProfile() {
    emit(
      _getCachedUser().when<ProfileState>(
        success: (user) => ProfileLoaded(user, _getSignInMethod()),
        failure: ProfileFailed.new,
      ),
    );
  }
}
