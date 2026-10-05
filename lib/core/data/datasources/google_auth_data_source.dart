abstract class GoogleAuthDataSource {
  /// Opens the Google account picker and returns the picked account's ID
  /// token, or null when the user closed the picker without choosing.
  Future<String?> getIdToken();

  /// Best effort: clears the Google sign-in state and never throws.
  Future<void> signOut();
}
