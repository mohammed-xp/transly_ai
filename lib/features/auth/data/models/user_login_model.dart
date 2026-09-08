import 'package:transly_ai/features/auth/data/models/user_model.dart';
import 'package:transly_ai/features/auth/data/models/user_token_model.dart';

class UserLoginModel {
  final UserTokenModel userTokenModel;
  final UserModel userModel;

  const UserLoginModel({
    required this.userTokenModel,
    required this.userModel,
  });

  factory UserLoginModel.fromJson(Map<String, dynamic> json) {
    return UserLoginModel(
      userTokenModel: UserTokenModel.fromJson(json),
      userModel: UserModel.fromJson(json['user']),
    );
  }
}