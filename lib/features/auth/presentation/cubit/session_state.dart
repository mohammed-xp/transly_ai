/// Whether the backend session is still valid, application-wide.
sealed class SessionState {
  const SessionState();
}

class SessionActive extends SessionState {
  const SessionActive();
}

/// The backend rejected the session token (HTTP 401) on an authenticated
/// request — the app must route back to sign-in.
class SessionExpired extends SessionState {
  const SessionExpired();
}

/// The user signed out deliberately (as opposed to the token being
/// rejected) — the app routes back to sign-in with no error message.
class SessionSignedOut extends SessionState {
  const SessionSignedOut();
}
