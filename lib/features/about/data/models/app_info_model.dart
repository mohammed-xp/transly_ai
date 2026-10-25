import '../../domain/entities/app_info_entity.dart';

class AppInfoModel {
  const AppInfoModel({required this.version});

  final String version;

  AppInfoEntity toEntity() => AppInfoEntity(version: version);
}
