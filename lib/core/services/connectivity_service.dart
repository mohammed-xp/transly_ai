import 'package:connectivity_plus/connectivity_plus.dart';

/// Thin abstraction over [Connectivity] so repositories can be unit-tested
/// without hitting platform channels. Lives in `core/services/` — a device
/// capability wrapper reused by the online translation source (and future
/// features), not a networking primitive.
abstract class ConnectivityService {
  /// `true` when the device reports any active transport (wifi/mobile/ethernet…).
  Future<bool> get isConnected;

  /// Emits `true`/`false` on every change in connectivity.
  Stream<bool> get onConnectedChanged;
}

class ConnectivityServiceImpl implements ConnectivityService {
  ConnectivityServiceImpl(this._connectivity);

  final Connectivity _connectivity;

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return _isConnected(results);
  }

  @override
  Stream<bool> get onConnectedChanged => _connectivity.onConnectivityChanged
      .map(_isConnected)
      .distinct();

  bool _isConnected(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
}
