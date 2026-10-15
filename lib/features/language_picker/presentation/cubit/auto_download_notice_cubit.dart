import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/language_entity.dart';
import '../../domain/entities/offline_model_status.dart';
import '../../domain/usecases/get_cached_languages_usecase.dart';
import '../../domain/usecases/get_offline_packs_settings_usecase.dart';
import '../../domain/usecases/watch_offline_model_updates_usecase.dart';
import 'auto_download_notice_state.dart';

/// Tells the user a language is downloading in the background after an
/// online translation, until it finishes or they hide the notice.
class AutoDownloadNoticeCubit extends Cubit<AutoDownloadNoticeState> {
  AutoDownloadNoticeCubit({
    required WatchOfflineModelUpdatesUseCase watchOfflineModelUpdates,
    required GetCachedLanguagesUseCase getCachedLanguages,
    required GetOfflinePacksSettingsUseCase getSettings,
  }) : _getCachedLanguages = getCachedLanguages,
       _getSettings = getSettings,
       super(const AutoDownloadNoticeHidden()) {
    _updatesSubscription = watchOfflineModelUpdates().listen(_onUpdate);
  }

  final GetCachedLanguagesUseCase _getCachedLanguages;
  final GetOfflinePacksSettingsUseCase _getSettings;

  late final StreamSubscription<OfflineModelUpdate> _updatesSubscription;

  /// Codes being auto-downloaded, oldest first. The newest one is shown.
  final List<String> _running = [];

  /// Codes whose notice the user hid while they were still downloading.
  final Set<String> _dismissed = {};

  /// The download itself goes on; only the notice goes away.
  void dismiss() {
    final state = this.state;
    if (isClosed || state is! AutoDownloadNoticeShown) return;
    _dismissed.add(state.language.code);
    _showNewest();
  }

  void _onUpdate(OfflineModelUpdate update) {
    _running.remove(update.code);
    if (update.status case OfflineModelDownloading(isAuto: true)) {
      _running.add(update.code);
    } else {
      _dismissed.remove(update.code);
    }
    _showNewest();
  }

  void _showNewest() {
    if (isClosed) return;
    for (final code in _running.reversed) {
      if (_dismissed.contains(code)) continue;
      final language = _languageOf(code);
      if (language == null) continue;
      emit(
        AutoDownloadNoticeShown(language, wifiOnly: _getSettings().wifiOnly),
      );
      return;
    }
    emit(const AutoDownloadNoticeHidden());
  }

  LanguageEntity? _languageOf(String code) {
    for (final language in _getCachedLanguages()) {
      if (language.code == code) return language;
    }
    return null;
  }

  @override
  Future<void> close() {
    unawaited(_updatesSubscription.cancel());
    return super.close();
  }
}
