import 'package:equatable/equatable.dart';

class ErrorEntity extends Equatable {
  final bool success;
  final String message;
  final Map<String, dynamic> errors;

  const ErrorEntity({
    required this.success,
    required this.message,
    required this.errors,
  });
  @override
  List<Object?> get props => [success, message, errors];
}
