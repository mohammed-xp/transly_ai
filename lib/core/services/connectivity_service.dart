import 'package:connectivity_plus/connectivity_plus.dart';

abstract interface class ConnectivityService {
  Future<bool> get isOnline;
  Stream<bool> get onConnectivityChanged;
}

final class ConnectivityServiceImpl implements ConnectivityService {
  ConnectivityServiceImpl(this._connectivity);

  final Connectivity _connectivity;

  @override
  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();
    return _hasConnection(results);
  }

  @override
  Stream<bool> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map(_hasConnection);

  bool _hasConnection(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
}
