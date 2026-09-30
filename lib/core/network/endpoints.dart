import 'package:flutter/foundation.dart';

abstract final class Endpoints {
  static const String baseUrlTest = 'http://192.168.1.147:5260';
  static const String baseUrlProduction = 'https://translyai-api.jollypond-1171c5b6.uaenorth.azurecontainerapps.io';

  static const String baseUrl = baseUrlProduction; // kDebugMode? baseUrl : baseUrlProduction;


  static const String translations = '$baseUrl/api/v1/translations';
  static const String login = '$baseUrl/api/v1/auth/login';
  static const String register = '$baseUrl/api/v1/auth/register';
  static const String deleteAccount = '$baseUrl/api/v1/auth/delete-account';
  static const String refreshToken = '$baseUrl/api/v1/auth/refresh-token';
  static const String usage = '$baseUrl/api/v1/usage';
}
