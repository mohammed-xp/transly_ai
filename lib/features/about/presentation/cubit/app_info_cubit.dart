import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_app_info_usecase.dart';
import 'app_info_state.dart';

class AppInfoCubit extends Cubit<AppInfoState> {
  AppInfoCubit({required GetAppInfoUseCase getAppInfo})
    : _getAppInfo = getAppInfo,
      super(const AppInfoLoading());

  final GetAppInfoUseCase _getAppInfo;

  Future<void> load() async {
    final result = await _getAppInfo();
    if (isClosed) return;
    emit(
      result.when<AppInfoState>(
        success: AppInfoLoaded.new,
        failure: AppInfoFailed.new,
      ),
    );
  }
}
