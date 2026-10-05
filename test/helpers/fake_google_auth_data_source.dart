import 'package:transly_ai/core/data/datasources/google_auth_data_source.dart';

class FakeGoogleAuthDataSource implements GoogleAuthDataSource {
  FakeGoogleAuthDataSource({this.idToken, this.error});

  /// Null plays the user closing the account picker.
  final String? idToken;

  /// When set, [getIdToken] throws it instead of answering.
  final Object? error;

  int signOuts = 0;

  @override
  Future<String?> getIdToken() async {
    final error = this.error;
    if (error != null) throw error;
    return idToken;
  }

  @override
  Future<void> signOut() async {
    signOuts++;
  }
}
