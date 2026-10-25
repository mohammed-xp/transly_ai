import '../models/app_info_model.dart';

abstract class AppInfoDataSource {
  Future<AppInfoModel> getAppInfo();
}
