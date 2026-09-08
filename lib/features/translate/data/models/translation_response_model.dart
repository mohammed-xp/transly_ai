import '../../../../core/errors/app_exceptions.dart';

/// Decoded response body of `POST /v1/translations`. Only [translatedText]
/// feeds the domain today; [model] and [createdAt] are carried for a future
/// history feature without changing this shape again.
class TranslationResponseModel {
  const TranslationResponseModel({
    required this.translatedText,
    this.model,
    this.createdAt,
  });

  factory TranslationResponseModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw const RemoteApiException('Unexpected response shape');
    }

    final translatedText = json['translatedText'];
    if (translatedText is! String || translatedText.isEmpty) {
      throw const RemoteApiException('Missing translatedText in response');
    }

    return TranslationResponseModel(
      translatedText: translatedText,
      model: json['model'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }

  final String translatedText;
  final String? model;
  final DateTime? createdAt;
}
