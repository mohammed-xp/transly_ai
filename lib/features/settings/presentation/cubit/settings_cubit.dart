import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/domain/entities/language.dart';
import '../../../../core/domain/entities/translation_tone.dart';
import '../../domain/entities/app_settings.dart';
import 'settings_state.dart';

final class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsLoaded(AppSettings()));

  AppSettings get _settings => switch (state) {
        SettingsLoaded(:final settings) => settings,
        SettingsLoading() => const AppSettings(),
      };

  void setDefaultPair(LanguagePair pair) =>
      emit(SettingsLoaded(_settings.copyWith(defaultPair: pair)));

  void setDefaultTone(TranslationTone tone) =>
      emit(SettingsLoaded(_settings.copyWith(defaultTone: tone)));

  void toggleAutoPlayAudio() =>
      emit(SettingsLoaded(_settings.copyWith(autoPlayAudio: !_settings.autoPlayAudio)));

  void toggleDarkMode() =>
      emit(SettingsLoaded(_settings.copyWith(useDarkMode: !_settings.useDarkMode)));
}
