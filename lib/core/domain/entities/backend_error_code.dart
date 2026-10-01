/// Error keys the backend sends in the ProblemDetails `detail` field. The app
/// translates each one itself, so the message follows the app's language.
enum BackendErrorCode {
  emailAlreadyRegistered('auth.email_already_registered'),
  invalidCredentials('auth.invalid_credentials'),
  invalidToken('auth.invalid_token'),
  wrongPassword('account.wrong_password'),
  quotaExceeded('translation.quota_exceeded'),
  textTooLong('translation.text_too_long'),
  translationServiceUnavailable('translation.service_unavailable'),
  translationTimeout('translation.timeout'),
  translationFailed('translation.failed'),
  unexpectedError('server.unexpected_error');

  const BackendErrorCode(this.key);

  final String key;

  /// Null for anything that isn't a known key, including the plain-English
  /// details older backend builds send.
  static BackendErrorCode? fromKey(String? key) {
    for (final code in values) {
      if (code.key == key) return code;
    }
    return null;
  }
}
