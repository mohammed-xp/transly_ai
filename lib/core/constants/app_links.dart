abstract final class AppLinks {
  static final Uri privacyPolicy = Uri.parse(
    'https://mohammed-xp.github.io/transly-privacy',
  );
  static final Uri termsOfService = Uri.parse(
    'https://mohammed-xp.github.io/transly-privacy/terms.html',
  );
  static final Uri playStoreListing = Uri.parse(
    'https://play.google.com/store/apps/details?id=tech.mohammedadil.transly',
  );

  static const String supportEmailAddress = 'traduly.ai@gmail.com';
  static final Uri supportEmail = Uri(
    scheme: 'mailto',
    path: supportEmailAddress,
  );
}
