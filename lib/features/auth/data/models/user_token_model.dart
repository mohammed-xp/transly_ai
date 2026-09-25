import '../../../../core/errors/app_exceptions.dart';

class UserTokenModel {
  const UserTokenModel({required this.accessToken, this.refreshToken});

  final String accessToken;
  final String? refreshToken;

  factory UserTokenModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) throw const ParsingException();

    final accessToken = json['accessToken'];
    if (accessToken is! String || accessToken.isEmpty) {
      throw const ParsingException();
    }

    final refreshToken = json['refreshToken'];
    return UserTokenModel(
      accessToken: accessToken,
      refreshToken: refreshToken is String ? refreshToken : null,
    );
  }
}
