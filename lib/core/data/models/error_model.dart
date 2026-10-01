import '../../domain/entities/backend_error_code.dart';
import '../../domain/entities/error_entity.dart';

class ErrorModel {
  final bool success;
  final String message;
  final Map<String, dynamic> errors;
  final BackendErrorCode? code;

  ErrorModel({
    this.success = false,
    required this.message,
    this.errors = const {},
    this.code,
  });

  /// Reads RFC 7807 ProblemDetails, whose `detail` carries a
  /// [BackendErrorCode] key, and falls back to the older `message` envelope.
  factory ErrorModel.fromJson(Map<String, dynamic> json) {
    final detail = json['detail'];
    final message = detail is String ? detail : json['message'];
    final errors = json['errors'];
    return ErrorModel(
      success: json['success'] == true,
      message: message is String ? message : '',
      errors: errors is Map ? Map<String, dynamic>.from(errors) : const {},
      code: BackendErrorCode.fromKey(detail is String ? detail.trim() : null),
    );
  }

  ErrorEntity toEntity() => ErrorEntity(
    message: message,
    success: success,
    errors: errors,
    code: code,
  );
}
