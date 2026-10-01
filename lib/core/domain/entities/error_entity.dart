import 'package:equatable/equatable.dart';

import 'backend_error_code.dart';

class ErrorEntity extends Equatable {
  final bool success;
  final String message;
  final Map<String, dynamic> errors;
  final BackendErrorCode? code;

  const ErrorEntity({
    required this.success,
    required this.message,
    required this.errors,
    this.code,
  });
  @override
  List<Object?> get props => [success, message, errors, code];
}
