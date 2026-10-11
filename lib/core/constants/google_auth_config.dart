/// OAuth client IDs for Google Sign-In. Client IDs are public identifiers, not
/// secrets — the client secret stays on the backend.
abstract final class GoogleAuthConfig {
  /// The *Web application* client ID: the audience the backend checks the
  /// Google ID token against. Not the Android client ID.
  static const String serverClientId =
      '507923045845-e6u3uut1sai4aj7hqtnpj369bds9ubdv.apps.googleusercontent.com';

  /// The *iOS* client ID. Android ignores it.
  static const String iosClientId =
      '507923045845-8gm437641js5tcaeaga0t3ap8slintn9.apps.googleusercontent.com';
}
