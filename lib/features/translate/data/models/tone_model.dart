import '../../domain/entities/translation_tone.dart';

class ToneModel {
  const ToneModel({
    required this.code,
    required this.name,
    required this.nameAr,
  });

  final String code;
  final String name;
  final String nameAr;

  factory ToneModel.fromJson(Map<String, dynamic> json) => ToneModel(
    code: json['code'] as String,
    name: json['name'] as String,
    nameAr: json['nameAr'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'nameAr': nameAr,
  };

  TranslationTone toEntity() =>
      TranslationTone(code: code, name: name, nameAr: nameAr);
}
