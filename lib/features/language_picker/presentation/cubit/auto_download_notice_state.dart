import '../../../../core/domain/entities/language_entity.dart';

sealed class AutoDownloadNoticeState {
  const AutoDownloadNoticeState();
}

class AutoDownloadNoticeHidden extends AutoDownloadNoticeState {
  const AutoDownloadNoticeHidden();
}

/// [language] is being auto-downloaded; [wifiOnly] when only over Wi-Fi.
class AutoDownloadNoticeShown extends AutoDownloadNoticeState {
  const AutoDownloadNoticeShown(this.language, {required this.wifiOnly});

  final LanguageEntity language;
  final bool wifiOnly;
}
