/// A newer store release than the installed build.
class AppUpdateEntity {
  const AppUpdateEntity({
    required this.installedVersion,
    required this.latestVersion,
    required this.releaseNotes,
    required this.isRequired,
  });

  final String installedVersion;
  final String latestVersion;

  /// One entry per line of the store's "What's new" text; empty when the
  /// store listing has none.
  final List<String> releaseNotes;

  /// The installed version is below the minimum supported one, so the app
  /// must not be used until it is updated.
  final bool isRequired;
}
