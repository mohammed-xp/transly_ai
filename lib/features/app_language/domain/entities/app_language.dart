import 'package:equatable/equatable.dart';

/// The language the app's UI is shown in: one of the app's supported
/// languages, or [device] to follow the phone's language setting (the
/// default). Which languages exist is decided by the app's translations, not
/// here.
class AppLanguage extends Equatable {
  const AppLanguage(String this.code);

  const AppLanguage._device() : code = null;

  static const device = AppLanguage._device();

  /// ISO 639-1 code; null for [device].
  final String? code;

  bool get isDevice => code == null;

  @override
  List<Object?> get props => [code];
}
