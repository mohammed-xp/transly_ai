import 'package:package_info_plus/package_info_plus.dart';

import '../models/app_info_model.dart';
import 'app_info_data_source.dart';

class AppInfoDataSourceImpl implements AppInfoDataSource {
  const AppInfoDataSourceImpl();

  @override
  Future<AppInfoModel> getAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    return AppInfoModel(version: info.version);
  }
}
