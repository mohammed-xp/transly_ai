import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/usecases/get_cached_user_use_case.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required GetCachedUserUseCase getCachedUser})
    : _getCachedUser = getCachedUser,
      super(const ProfileInitial());

  final GetCachedUserUseCase _getCachedUser;

  void loadProfile() {
    emit(
      _getCachedUser().when<ProfileState>(
        success: ProfileLoaded.new,
        failure: ProfileFailed.new,
      ),
    );
  }
}
