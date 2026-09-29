import '../../domain/entities/app_update_entity.dart';

class AppUpdateModel {
  const AppUpdateModel({
    required this.installedVersion,
    required this.latestVersion,
    required this.isRequired,
    this.releaseNotes,
  });

  final String installedVersion;
  final String latestVersion;
  final bool isRequired;

  /// The store's raw "What's new" text, one item per line.
  final String? releaseNotes;

  static final RegExp _lineBreak = RegExp(r'\r?\n');
  static final RegExp _leadingBullet = RegExp(r'^[-•*·]\s*');

  AppUpdateEntity toEntity() {
    return AppUpdateEntity(
      installedVersion: installedVersion,
      latestVersion: latestVersion,
      releaseNotes: _splitReleaseNotes(releaseNotes),
      isRequired: isRequired,
    );
  }

  static List<String> _splitReleaseNotes(String? notes) {
    if (notes == null) return const [];
    return notes
        .split(_lineBreak)
        .map((line) => line.trim().replaceFirst(_leadingBullet, '').trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
  }
}
