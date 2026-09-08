import '../../../../core/errors/app_exceptions.dart';

class UserTokenModel {
  const UserTokenModel({required this.accessToken});

  final String accessToken;

  factory UserTokenModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw const RemoteApiException('Unexpected response shape');
    }

    final accessToken = json['accessToken'];
    if (accessToken is! String || accessToken.isEmpty) {
      throw const RemoteApiException('Missing access token in response');
    }

    return UserTokenModel(
      accessToken: accessToken,
    );
  }

}
