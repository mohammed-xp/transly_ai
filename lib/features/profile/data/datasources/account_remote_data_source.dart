abstract class AccountRemoteDataSource {
  Future<void> deleteAccount({required String password});

  Future<void> deleteAccountWithGoogle({required String idToken});
}
