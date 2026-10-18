import '../../domain/entities/translation_tone.dart';

class ToneModel {
  const ToneModel({required this.code, required this.name});

  final String code;
  final String name;

  factory ToneModel.fromJson(Map<String, dynamic> json) =>
      ToneModel(code: json['code'] as String, name: json['name'] as String);

  Map<String, dynamic> toJson() => {'code': code, 'name': name};

  TranslationTone toEntity() => TranslationTone(code: code, name: name);
}
