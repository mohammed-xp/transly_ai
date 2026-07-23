import 'package:dio/dio.dart';

import '../errors/app_exceptions.dart';
import 'rest_client.dart';

/// [RestClient] implementation backed by [Dio] — the only file in the project
/// that imports `package:dio` for outgoing requests.
class DioRestClient implements RestClient {
  DioRestClient(this._dio);

  final Dio _dio;

  @override
  Future<dynamic> postJson(
    String url, {
    Map<String, String>? headers,
    required Object body,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        url,
        options: Options(headers: {
          'Content-Type': 'application/json',
          ...?headers,
        }),
        data: body,
      );
      return response.data;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  AppException _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return RemoteConnectionException(e.message);
      case DioExceptionType.badResponse:
        return RemoteApiException('HTTP ${e.response?.statusCode}');
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return RemoteApiException(e.message);
    }
  }
}
