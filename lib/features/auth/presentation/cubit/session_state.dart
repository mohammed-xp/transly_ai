/// Whether the backend session is still valid, application-wide.
sealed class SessionState {
  const SessionState();
}

class SessionActive extends SessionState {
  const SessionActive();
}

/// The backend rejected the session token — the app must route back to
/// sign-in and tell the user why.
class SessionExpired extends SessionState {
  const SessionExpired();
}

/// The user signed out deliberately — route back to sign-in silently.
class SessionSignedOut extends SessionState {
  const SessionSignedOut();
}
