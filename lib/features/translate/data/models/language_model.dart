import '../../../../core/domain/entities/language_entity.dart';

class LanguageModel {
  final String code;
  final String name;
  final String nativeName;
  final bool isRtl;

  const LanguageModel({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.isRtl,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      code: json['code'],
      name: json['name'],
      nativeName: json['nativeName'],
      isRtl: json['isRtl'],
    );
  }

  factory LanguageModel.fromEntity(LanguageEntity entity) => LanguageModel(
    code: entity.code,
    name: entity.name,
    nativeName: entity.nativeName,
    isRtl: entity.isRtl,
  );

  LanguageEntity toEntity() => LanguageEntity(
    code: code,
    name: name,
    nativeName: nativeName,
    isRtl: isRtl,
  );
}
