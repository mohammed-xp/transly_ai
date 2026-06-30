import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/domain/entities/language.dart';
import 'camera_scan_state.dart';

final class CameraScanCubit extends Cubit<CameraScanState> {
  CameraScanCubit() : super(const CameraScanIdle());

  LanguagePair get _pair => switch (state) {
        CameraScanIdle(:final pair) => pair,
        CameraScanScanning(:final pair) => pair,
        CameraScanSuccess(:final result) => result.pair,
        CameraScanError() => LanguagePair.enToAr,
      };

  void startScan() => emit(CameraScanScanning(pair: _pair));

  void reset() => emit(CameraScanIdle(pair: _pair));

  void setLanguagePair(LanguagePair pair) => emit(CameraScanIdle(pair: pair));
}
