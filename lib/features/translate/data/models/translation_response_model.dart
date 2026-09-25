import '../../domain/entities/translation_engine.dart';
import '../../domain/entities/translation_entity.dart';
import 'language_model.dart';

class TranslationResponseModel {
  final String sourceText;
  final String translatedText;
  final LanguageModel sourceLanguage;
  final LanguageModel targetLanguage;
  final String model;
  final DateTime createdAt;

  const TranslationResponseModel({
    required this.sourceText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.model,
    required this.createdAt,
  });

  factory TranslationResponseModel.fromJson(dynamic json) {
    return TranslationResponseModel(
      sourceText: json['sourceText'],
      translatedText: json['translatedText'],
      sourceLanguage: LanguageModel.fromJson(json['sourceLanguage']),
      targetLanguage: LanguageModel.fromJson(json['targetLanguage']),
      model: json['model'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  TranslationEntity toEntity(TranslationEngine engine) {
    return TranslationEntity(
      sourceText: sourceText,
      translatedText: translatedText,
      from: sourceLanguage.toEntity(),
      to: targetLanguage.toEntity(),
      model: model,
      engine: engine,
    );
  }
}
