import '../../../../core/data/models/user_model.dart';
import 'user_token_model.dart';

class UserLoginModel {
  const UserLoginModel({required this.userTokenModel, required this.userModel});

  final UserTokenModel userTokenModel;
  final UserModel userModel;

  factory UserLoginModel.fromJson(Map<String, dynamic> json) {
    return UserLoginModel(
      userTokenModel: UserTokenModel.fromJson(json['token']),
      userModel: UserModel.fromJson(json['user']),
    );
  }
}
