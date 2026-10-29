import '../../../../core/services/connectivity_service.dart';

/// Whether the device is online: the current answer, then every change.
class WatchConnectionUseCase {
  const WatchConnectionUseCase(this._connectivity);

  final ConnectivityService _connectivity;

  Stream<bool> call() async* {
    yield await _connectivity.isConnected;
    yield* _connectivity.onConnectedChanged;
  }
}
