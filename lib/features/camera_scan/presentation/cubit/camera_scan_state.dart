import 'package:equatable/equatable.dart';
import '../../../../core/domain/entities/language.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/scan_result.dart';

sealed class CameraScanState extends Equatable {
  const CameraScanState();
  @override
  List<Object?> get props => [];
}

final class CameraScanIdle extends CameraScanState {
  const CameraScanIdle({this.pair = LanguagePair.enToAr});
  final LanguagePair pair;
  @override
  List<Object?> get props => [pair];
}

final class CameraScanScanning extends CameraScanState {
  const CameraScanScanning({required this.pair});
  final LanguagePair pair;
  @override
  List<Object?> get props => [pair];
}

final class CameraScanSuccess extends CameraScanState {
  const CameraScanSuccess({required this.result});
  final ScanResult result;
  @override
  List<Object?> get props => [result];
}

final class CameraScanError extends CameraScanState {
  const CameraScanError({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
