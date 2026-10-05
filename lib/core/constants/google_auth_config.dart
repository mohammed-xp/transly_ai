/// OAuth client IDs for Google Sign-In. Client IDs are public identifiers, not
/// secrets — the client secret stays on the backend.
abstract final class GoogleAuthConfig {
  /// The *Web application* client ID: the audience the backend checks the
  /// Google ID token against. Not the Android client ID.
  static const String serverClientId =
      'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';

  /// The *iOS* client ID. Android ignores it; leave null until iOS is set up.
  static const String? iosClientId = null;
}
