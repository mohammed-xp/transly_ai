class UserEntity {
  const UserEntity({required this.id, required this.email, required this.username, required this.createdAt});

  final String id;
  final String email;
  final String username;
  final DateTime createdAt;
}
