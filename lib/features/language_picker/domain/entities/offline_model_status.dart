/// Whether a language can be translated without a connection.
sealed class OfflineModelStatus {
  const OfflineModelStatus();
}

/// The on-device engine has no model for the language.
class OfflineModelUnsupported extends OfflineModelStatus {
  const OfflineModelUnsupported();
}

/// Ships with the device: always there, can't be removed.
class OfflineModelBuiltIn extends OfflineModelStatus {
  const OfflineModelBuiltIn();
}

class OfflineModelNotDownloaded extends OfflineModelStatus {
  const OfflineModelNotDownloaded();
}

class OfflineModelDownloading extends OfflineModelStatus {
  const OfflineModelDownloading();
}

class OfflineModelDownloaded extends OfflineModelStatus {
  const OfflineModelDownloaded();
}

typedef OfflineModelUpdate = ({String code, OfflineModelStatus status});
