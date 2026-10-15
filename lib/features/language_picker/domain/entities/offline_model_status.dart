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

/// [isAuto]: started by auto-download after an online translation rather
/// than by the user.
class OfflineModelDownloading extends OfflineModelStatus {
  const OfflineModelDownloading({this.isAuto = false});

  final bool isAuto;
}

/// [isAuto]: downloaded by auto-download rather than by the user.
class OfflineModelDownloaded extends OfflineModelStatus {
  const OfflineModelDownloaded({this.isAuto = false});

  final bool isAuto;
}

typedef OfflineModelUpdate = ({String code, OfflineModelStatus status});
