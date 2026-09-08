import 'package:transly_ai/features/auth/domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String email;
  final String username;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['userName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      username: username,
      createdAt: createdAt,
    );
  }
}