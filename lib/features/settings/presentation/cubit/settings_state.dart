import 'package:equatable/equatable.dart';
import '../../domain/entities/app_settings.dart';

sealed class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object?> get props => [];
}

final class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

final class SettingsLoaded extends SettingsState {
  const SettingsLoaded(this.settings);
  final AppSettings settings;

  @override
  List<Object?> get props => [settings];
}
