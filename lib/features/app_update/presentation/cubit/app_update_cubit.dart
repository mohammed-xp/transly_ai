import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/api_result.dart';
import '../../domain/entities/app_update_entity.dart';
import '../../domain/usecases/check_for_app_update_usecase.dart';
import '../../domain/usecases/mark_app_update_prompted_usecase.dart';
import '../../domain/usecases/open_app_store_usecase.dart';
import 'app_update_state.dart';

class AppUpdateCubit extends Cubit<AppUpdateState> {
  AppUpdateCubit({
    required CheckForAppUpdateUseCase checkForUpdate,
    required MarkAppUpdatePromptedUseCase markPrompted,
    required OpenAppStoreUseCase openStore,
  }) : _checkForUpdate = checkForUpdate,
       _markPrompted = markPrompted,
       _openStore = openStore,
       super(const AppUpdateChecking());

  final CheckForAppUpdateUseCase _checkForUpdate;
  final MarkAppUpdatePromptedUseCase _markPrompted;
  final OpenAppStoreUseCase _openStore;

  Future<void> checkForUpdate() async {
    final result = await _checkForUpdate();
    if (isClosed) return;
    emit(
      result.when<AppUpdateState>(
        success: (update) => switch (update) {
          null => const AppUpdateNone(),
          final AppUpdateEntity entity when entity.isRequired =>
            AppUpdateRequired(entity),
          final AppUpdateEntity entity => AppUpdateOptional(entity),
        },
        failure: AppUpdateCheckFailed.new,
      ),
    );
  }

  /// Called once the optional-update sheet is on screen so it isn't shown
  /// again. A failed save only means the prompt may return on a later launch.
  Future<void> optionalUpdatePrompted() async {
    if (state is! AppUpdateOptional) return;
    emit(const AppUpdateNone());
    await _markPrompted();
  }

  /// Whether the store listing could be opened.
  Future<bool> openStore() async {
    final result = await _openStore();
    return result is ApiSuccess<void>;
  }
}
