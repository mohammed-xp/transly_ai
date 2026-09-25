abstract final class Endpoints {
  static const String baseUrl = 'http://192.168.1.147:5260';

  static const String translations = '$baseUrl/api/v1/translations';
  static const String login = '$baseUrl/api/v1/auth/login';
  static const String register = '$baseUrl/api/v1/auth/register';
  static const String refreshToken = '$baseUrl/api/v1/auth/refresh-token';
}
