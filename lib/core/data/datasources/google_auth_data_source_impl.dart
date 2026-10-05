import 'dart:developer';

import 'package:google_sign_in/google_sign_in.dart';

import '../../errors/app_exceptions.dart';
import 'google_auth_data_source.dart';

class GoogleAuthDataSourceImpl implements GoogleAuthDataSource {
  GoogleAuthDataSourceImpl(
    this._googleSignIn, {
    required String serverClientId,
    String? clientId,
  }) : _serverClientId = serverClientId,
       _clientId = clientId;

  final GoogleSignIn _googleSignIn;
  final String _serverClientId;
  final String? _clientId;

  Future<void>? _initialization;

  /// `initialize` must run once, and finish, before any other plugin call.
  Future<void> _ensureInitialized() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    try {
      await _googleSignIn.initialize(
        clientId: _clientId,
        serverClientId: _serverClientId,
      );
    } catch (_) {
      // Let the next attempt retry instead of replaying this failure forever.
      _initialization = null;
      rethrow;
    }
  }

  @override
  Future<String?> getIdToken() async {
    try {
      await _ensureInitialized();
      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) throw const UnknownException();
      return idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      // The code tells a wrong SHA-1 / client ID apart from a real failure.
      log('${e.code.name}: ${e.description}', name: 'GoogleAuthDataSource');
      throw const UnknownException();
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _ensureInitialized();
      await _googleSignIn.signOut();
    } catch (e) {
      log('signOut failed: ${e.runtimeType}', name: 'GoogleAuthDataSource');
    }
  }
}
