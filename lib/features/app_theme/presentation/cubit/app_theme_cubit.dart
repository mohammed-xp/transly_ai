import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/api_result.dart';
import '../../domain/entities/app_theme_mode.dart';
import '../../domain/usecases/get_app_theme_mode_usecase.dart';
import '../../domain/usecases/set_app_theme_mode_usecase.dart';

/// App-wide appearance, provided above `MaterialApp`. The state is the chosen
/// [AppThemeMode] itself — there is no loading or error state because the
/// saved choice is read synchronously.
class AppThemeCubit extends Cubit<AppThemeMode> {
  AppThemeCubit({
    required GetAppThemeModeUseCase getThemeMode,
    required SetAppThemeModeUseCase setThemeMode,
  }) : _setThemeMode = setThemeMode,
       super(getThemeMode());

  final SetAppThemeModeUseCase _setThemeMode;

  /// Switches only once the choice is saved, so the app never shows an
  /// appearance it would forget on the next launch. Returns whether it saved.
  Future<bool> changeThemeMode(AppThemeMode mode) async {
    if (mode == state) return true;
    final result = await _setThemeMode(mode);
    if (result is! ApiSuccess<void>) return false;
    if (!isClosed) emit(mode);
    return true;
  }
}
