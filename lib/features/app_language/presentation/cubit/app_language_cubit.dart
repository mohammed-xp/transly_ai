import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/api_result.dart';
import '../../domain/entities/app_language.dart';
import '../../domain/usecases/get_app_language_usecase.dart';
import '../../domain/usecases/set_app_language_usecase.dart';

/// App-wide UI language, provided above `MaterialApp`. The state is the
/// chosen [AppLanguage] itself — there is no loading or error state because
/// the saved choice is read synchronously.
class AppLanguageCubit extends Cubit<AppLanguage> {
  AppLanguageCubit({
    required GetAppLanguageUseCase getLanguage,
    required SetAppLanguageUseCase setLanguage,
  }) : _setLanguage = setLanguage,
       super(getLanguage());

  final SetAppLanguageUseCase _setLanguage;

  /// Switches only once the choice is saved, so the app never shows a
  /// language it would forget on the next launch. Returns whether it saved.
  Future<bool> changeLanguage(AppLanguage language) async {
    if (language == state) return true;
    final result = await _setLanguage(language);
    if (result is! ApiSuccess<void>) return false;
    if (!isClosed) emit(language);
    return true;
  }
}
