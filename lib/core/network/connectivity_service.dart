import 'package:connectivity_plus/connectivity_plus.dart';

/// Thin abstraction over [Connectivity] so repositories can be unit-tested
/// without hitting platform channels. Shared infra — lives in core/ because the
/// online translation source (and future features) will reuse it.
abstract class ConnectivityService {
  /// `true` when the device reports any active transport (wifi/mobile/ethernet…).
  Future<bool> get isConnected;
}

class ConnectivityServiceImpl implements ConnectivityService {
  ConnectivityServiceImpl(this._connectivity);

  final Connectivity _connectivity;

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }
}
