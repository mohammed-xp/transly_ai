/// [autoDownload]: download the languages of an online translation in the
/// background so they work offline next time. [wifiOnly]: only do so on
/// Wi-Fi.
typedef OfflinePacksSettings = ({bool autoDownload, bool wifiOnly});

const OfflinePacksSettings defaultOfflinePacksSettings = (
  autoDownload: true,
  wifiOnly: true,
);
