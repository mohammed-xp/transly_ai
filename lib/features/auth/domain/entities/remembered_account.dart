/// The "remember me" state saved from a previous sign-in, used to prefill the
/// sign-in form. Pure Dart.
class RememberedAccount {
  const RememberedAccount({required this.isRemembered, required this.email});

  factory RememberedAccount.none() =>
      const RememberedAccount(isRemembered: false, email: '');

  final bool isRemembered;
  final String email;
}
