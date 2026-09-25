import '../../domain/entities/error_entity.dart';

class ErrorModel {
  final bool success;
  final String message;
  final Map<String, dynamic> errors;

  ErrorModel({
    this.success = false,
    required this.message,
    this.errors = const {},
  });

  factory ErrorModel.fromJson(Map<String, dynamic> json) => ErrorModel(
    success: json['success'] ?? false,
    message: json['message'] ?? '---',
    errors: json['errors'] ?? {},
  );

  ErrorEntity toEntity() =>
      ErrorEntity(message: message, success: success, errors: errors);
}
